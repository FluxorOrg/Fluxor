/*
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
open class Store<State: Encodable, Environment>: ObservableObject {
    @Published public private(set) var state: State
    internal private(set) var stateHash = UUID()
    private var stateHashSink: AnyCancellable!
    private let actions = PassthroughSubject<Action, Never>()
    private let environment: Environment
    private var reducers = [Reducer<State>]()
    private var effectCancellables = Set<AnyCancellable>()
    private var interceptors = [AnyInterceptor<State>]()

    /**
     Initializes the `Store` with an initial `State`, an `Environment` and eventually `Reducer`s.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter environment: The `Environment` to pass to `Effect`s
     - Parameter reducers: The `Reducer`s to register
     */
    public init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        state = initialState
        self.environment = environment
        stateHashSink = $state.sink { _ in self.stateHash = UUID() }
        reducers.forEach(register(reducer:))
    }

    /**
     Dispatches an `Action` and creates a new `State` by running the current `State` and the `Action`
     through all registered `Reducer`s.

     After the `State` is set, all registered `Interceptor`s are notified of the change.
     Lastly the `Action` is dispatched to all registered `Effect`s.

     - Parameter action: The `Action` to dispatch
     */
    public func dispatch(action: Action) {
        let oldState = state
        var newState = oldState
        reducers.forEach { $0.reduce(&newState, action) }
        state = newState
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: newState) }
        actions.send(action)
    }

    /**
     Registers the given `Reducer`. The `Reducer` will be run for all subsequent actions.

     - Parameter reducer: The `Reducer` to register
     */
    public func register(reducer: Reducer<State>) {
        reducers.append(reducer)
    }

    /**
     Registers the given `Effects`. The `Effects` will receive all subsequent actions.

     - Parameter effects: The `Effects` to register
     */
    public func register<E: Effects>(effects: E) where E.Environment == Environment {
        register(effects: effects.enabledEffects)
    }

    /**
     Registers the given `Effect`s. The `Effect`s will receive all subsequent actions.

     - Parameter effects: The array of `Effect`s to register
     */
    public func register(effects: [Effect<Environment>]) {
        effects.forEach(register(effect:))
    }

    /**
     Registers the given `Effect`. The `Effect` will receive all subsequent actions.

     - Parameter effect: The `Effect` to register
     */
    public func register(effect: Effect<Environment>) {
        let cancellable: AnyCancellable
        switch effect {
        case .dispatchingOne(let effectCreator):
            cancellable = effectCreator(actions.eraseToAnyPublisher(), environment)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: self.dispatch(action:))
        case .dispatchingMultiple(let effectCreator):
            cancellable = effectCreator(actions.eraseToAnyPublisher(), environment)
                .receive(on: DispatchQueue.main)
                .sink { $0.forEach(self.dispatch(action:)) }
        case .nonDispatching(let effectCreator):
            cancellable = effectCreator(actions.eraseToAnyPublisher(), environment)
        }
        cancellable.store(in: &effectCancellables)
    }

    /**
     Registers the given `Interceptor`. The `Interceptor` will receive all subsequent `Action`s and state changes.

     The associated type `State` on the `Interceptor` must match the generic `State` on the `Store`.

     - Parameter interceptor: The `Interceptor` to register
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
        return $state.map { selector.map($0, stateHash: self.stateHash) }.eraseToAnyPublisher()
    }

    /**
     Gets the current value in the `State` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     - Returns: The current `Value` in the `State`
     */
    public func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return selector.map(state, stateHash: stateHash)
    }
}

public extension Store where Environment == Void {
    /**
     Initializes the `Store` with an initial `State` and eventually `Reducer`s.

     Using this initializer will give all `Effects` a `Void` environment.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter reducers: The `Reducer`s to register
     */
    convenience init(initialState: State, reducers: [Reducer<State>] = []) {
        self.init(initialState: initialState, environment: Void(), reducers: reducers)
    }
}
