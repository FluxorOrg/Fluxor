/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import struct Foundation.UUID

// swiftlint:disable large_tuple

/**
 A `Mockstore` is intended to be used in unit tests where you want to set a new `State` directly
 or override the value coming out of `Selector`s.
 */
public class MockStore<State: Encodable, Environment>: Store<State, Environment> {
    /// All the `Action`s and state changes that has happened.
    public var stateChanges: [(action: Action, oldState: State, newState: State)] {
        self.testInterceptor.stateChanges
    }

    private let setState = ActionTemplate(id: "Set State", payloadType: State.self)
    private var overridenSelectorValues = [UUID: Any]()
    private let testInterceptor = TestInterceptor<State>()

    /**
     Initializes the `MockStore` with an initial `State`.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter reducers: The `Reducer`s to register
     - Parameter effects: The `Effect`s to register
     */
    public override init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        let reducers = reducers + [Reducer(ReduceOn(setState) { state, action in
            state = action.payload
        })]
        super.init(initialState: initialState, environment: environment, reducers: reducers)
        super.register(interceptor: self.testInterceptor)
    }

    /**
     Sets a new `State` on the `Store`.

     - Parameter newState: The new `State` to set on the `Store`
     */
    public func setState(newState: State) {
        self.dispatch(action: self.setState(payload: newState))
    }

    /**
     Overrides the `Selector` with a 'default' value.

     When a `Selector` is overriden it will always give the same value when used to select from this `MockStore`.

     - Parameter selector: The `Selector` to override
     - Parameter value: The value the `Selector` should give when selecting
     */
    public func overrideSelector<Value>(_ selector: Selector<State, Value>, value: Value) {
        overridenSelectorValues[selector.id] = value
    }
    
    /**
     Resets all overridden `Selector`s on this `MockStore`.
     */
    public func resetOverriddenSelectors() {
        overridenSelectorValues.removeAll()
    }

    public override func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        guard let value = overridenSelectorValues[selector.id] as? Value else { return super.select(selector) }
        return $state.map { _ in value }.eraseToAnyPublisher()
    }
    
    public override func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return overridenSelectorValues[selector.id] as? Value ?? super.selectCurrent(selector)
    }
}
