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

 ## Usage
 To update the `State` callers dispatch `Action`s on the `Store`.

 ## Selecting
 To select a value in the `State` the callers can either use a `Selector` or a key path.
 It is possible to get a `Publisher` for the value or just to select the current value.

 ## Interceptors
 It is possible to intercept all `Action`s and `State` changes by registering an `Interceptor`.
 */
open class Store<State: Encodable> {
    internal private(set) var state: CurrentValueSubject<State, Never>
    internal private(set) var stateHash = UUID()
    private var stateHashSink: AnyCancellable!
    private let actions = PassthroughSubject<Action, Never>()
    private(set) var reducers = [Reducer<State>]()
    private(set) var effectCancellables = Set<AnyCancellable>()
    private(set) var interceptors = [AnyInterceptor<State>]()

    /**
     Initializes the `Store` with an initial `State`.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter reducers: The `Reducer`s to register
     - Parameter effects: The `Effect`s to register
     */
    public init(initialState: State, reducers: [Reducer<State>] = [], effects: [Effects] = []) {
        state = .init(initialState)
        stateHashSink = state.sink { _ in self.stateHash = UUID() }
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
        let oldState = state.value
        var newState = oldState
        reducers.forEach { $0.reduce(&newState, action) }
        state.send(newState)
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: newState) }
        actions.send(action)
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
        effects.enabledEffects.forEach { effect in
            let cancellable: AnyCancellable
            switch effect {
            case .dispatchingOne(let effectCreator):
                cancellable = effectCreator(actions.eraseToAnyPublisher())
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: self.dispatch(action:))
            case .dispatchingMultiple(let effectCreator):
                cancellable = effectCreator(actions.eraseToAnyPublisher())
                    .receive(on: DispatchQueue.main)
                    .sink { $0.forEach(self.dispatch(action:)) }
            case .nonDispatching(let effectCreator):
                cancellable = effectCreator(actions.eraseToAnyPublisher())
            }
            cancellable.store(in: &effectCancellables)
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
     - Returns: A `Publisher` for the `Value` in the `State`
     */
    public func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        return state.map { selector.map($0, stateHash: self.stateHash) }.eraseToAnyPublisher()
    }

    /**
     Creates a `Publisher` for a `KeyPath` in the `State`.

     - Parameter keyPath: The key path to use when getting the value in the `State`
     - Returns: A `Publisher` for the `Value` in the `State`
     */
    public func select<Value>(_ keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        return state.map(keyPath).eraseToAnyPublisher()
    }

    /**
     Gets the current value in the `State` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     - Returns: The `Value` in the `State`
     */
    public func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return selector.map(state.value, stateHash: stateHash)
    }

    /**
     Gets the current value in the `State` for a `KeyPath`.

     - Parameter keyPath: The key path to use when getting the value in the `State`
     - Returns: The `Value` in the `State`
     */
    public func selectCurrent<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        return state.value[keyPath: keyPath]
    }
}
