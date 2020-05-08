/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Dispatch
import struct Foundation.UUID

/**
 The `Store` is a centralized container for a single-source-of-truth `State`.

 A `Store` is configured by registering all the desired `Reducer`s and  `Effects`s.

 # Usage
 To update the `State` callers dispatch `Action`s on the `Store`.

 # Interceptors
 It is possible to intercept all `Action`s and `State` changes by registering an `Interceptor`.

 # Selecting
 To select a value in the `State` the callers can either use a `Selector` or a key path.
 It is possible to get a `Publisher` for the value or just to select the current value.
 */
open class Store<State: Encodable>: ObservableObject {
    @Published internal fileprivate(set) var state: State { willSet { stateHash = UUID() } }
    internal private(set) var stateHash = UUID()
    private(set) var action = PassthroughSubject<Action, Never>()
    private(set) var reducers = [Reducer<State>]()
    private(set) var effectCancellables = Set<AnyCancellable>()
    private(set) var interceptors = [AnyInterceptor<State>]()

    /**
     Initializes the `Store` with an initial state and an `InitialAction`.

     - Parameter initialState: The initial state for the store
     - Parameter reducers: The `Reducer`s to register
     - Parameter effects: The `Effect`s to register
     */
    public init(initialState: State, reducers: [Reducer<State>] = [], effects: [Effects] = []) {
        state = initialState
        reducers.forEach(register(reducer:))
        effects.forEach(register(effects:))
    }

    /**
     Dispatches an action and creates a new `State` by running the current `State` and the `Action`
     through all registered `Reducer`s.

     After the `State` is set, all registered `Interceptor`s are notified of the change.
     Lastly the `Action` is dispatched to all registered `Effect`s.

     - Parameter action: The action to dispatch
     */
    public func dispatch(action: Action) {
        let oldState = state
        var newState = oldState
        reducers.forEach { $0.reduce(&newState, action) }
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: newState) }
        state = newState
        self.action.send(action)
    }

    /**
     Registers the given reducer. The reducer will be run for all subsequent actions.

     - Parameter reducer: The reducer to register
     */
    public func register(reducer: Reducer<State>) {
        reducers.append(reducer)
    }

    /**
     Registers the given effects. The effects will receive all subsequent actions.

     - Parameter effects: The effects type to register
     */
    public func register(effects: Effects) {
        effects.effects.forEach { effect in
            switch effect {
            case .dispatching(let effectCreator):
                effectCreator(action.eraseToAnyPublisher())
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: self.dispatch(action:))
                    .store(in: &effectCancellables)
            case .nonDispatching(let effectCreator):
                effectCreator(action.eraseToAnyPublisher())
                    .store(in: &effectCancellables)
            }
        }
    }

    /**
     Registers the given interceptor. The interceptor will receive all subsequent actions and state changes.

     The associated type `State` on the interceptor must match the generic `State` on the `Store`.

     - Parameter interceptor: The interceptor to register
     */
    public func register<I: Interceptor>(interceptor: I) where I.State == State {
        interceptors.append(AnyInterceptor(interceptor))
    }

    /**
     Creates a `Publisher` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     */
    public func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        return $state.map { selector.map($0, stateHash: self.stateHash) }.eraseToAnyPublisher()
    }

    /**
     Creates a `Publisher` for a `KeyPath` in the `State`.

     - Parameter keyPath: The key path to use when getting the value in the `State`
     */
    public func select<Value>(_ keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        return $state.map(keyPath).eraseToAnyPublisher()
    }

    /**
     Gets the current value in the `State` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     */
    public func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return selector.map(state, stateHash: stateHash)
    }

    /**
     Gets the current value in the `State` for a `Key path`.

     - Parameter keyPath: The key path to use when getting the value in the `State`
     */
    public func selectCurrent<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        return state[keyPath: keyPath]
    }
}
