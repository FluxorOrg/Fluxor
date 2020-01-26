/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Dispatch
import Foundation.NSUUID

/// An empty action used for initializing the `Store`.
public struct InitialAction: Action {}

/**
 The `Store` is a centralized container for a single-source-of-truth `State`.

 A `Store` is configured by registering all the desired `Reducer`s and  `Effects`s.

 # Usage
 To update the `State` callers dispatch `Action`s on the `Store`.

 # Interceptors
 It is possible to intercept all `Action`s and `State` changes by registering an `StoreInterceptor`.

 # Selecting
 To select a value in the `State` the callers can either use a selector (closure) or a key path. It is possible to get a `Publisher` for the value or just to selec the current value.
 */
public class Store<State: Encodable>: ObservableObject {
    internal private(set) var stateHash = UUID()
    @Published internal fileprivate(set) var state: State { willSet { stateHash = UUID() } }
    @Published internal private(set) var action: Action = InitialAction()
    internal private(set) var reducers = [AnyReducer<State>]()
    internal private(set) var effectCancellables = Set<AnyCancellable>()
    internal private(set) var interceptors = [AnyStoreInterceptor<State>]()

    /**
     Initializes the `Store` with an initial state and an `InitialAction`.

     - Parameter initialState: The initial state for the store
     */
    public init(initialState: State) {
        state = initialState
    }

    /**
     Dispatches an action and creates a new `State` by running the current `State` and the action through all registered reducers.

     After the `State` is set, all registered interceptors are notified of the change.
     Lastly the action is dispatched to all registered effects.

     - Parameter action: The action to dispatch
     */
    public func dispatch(action: Action) {
        let oldState = state
        state = reducers.reduce(state) { $1.reduce(state: $0, action: action) }
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: state) }
        self.action = action
    }

    /**
     Registers the given reducer. The reducer will be run for all subsequent actions.

     - Parameter reducer: The reducer to register
     */
    public func register<R: Reducer>(reducer: R) where R.State == State {
        reducers.append(AnyReducer(reducer))
    }

    /**
     Registers the given effects. The effects will receive all subsequent actions.

     - Parameter effects: The effects type to register
     */
    public func register(effects: Effects.Type) {
        effects.init($action).effects.forEach {
            if case Effect.dispatching(let publisher) = $0 {
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: self.dispatch(action:))
                    .store(in: &effectCancellables)
            } else if case Effect.nonDispatching(let cancellable) = $0 {
                cancellable
                    .store(in: &effectCancellables)
            }
        }
    }

    /**
     Registers the given interceptor. The interceptor will receive all subsequent actions and state changes.

     The associated type `State` on the interceptor must match the generic `State` on the `Store`.

     - Parameter interceptor: The interceptor to register
     */
    public func register<S: StoreInterceptor>(interceptor: S) where S.State == State {
        interceptors.append(AnyStoreInterceptor(interceptor))
    }

    /**
     Creates a `Publisher` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     */
    public func select<Value>(_ selector: MemoizedSelector<State, Value>) -> AnyPublisher<Value, Never> {
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
    public func selectCurrent<Value>(_ selector: MemoizedSelector<State, Value>) -> Value {
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
