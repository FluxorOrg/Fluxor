/**
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor

/**
 A `Mockstore` is intended to be used in unit tests where you want to set a new `State` directly
 or override the value coming out of `Selector`s.
 */
public class MockStore<State: Encodable>: Store<State> {
    private let setState = ActionTemplate(id: "Set State", payloadType: State.self)

    public override init(initialState: State, reducers: [Reducer<State>] = [], effects: [Effects] = []) {
        let reducers = reducers + [Reducer<State>(ReduceOn(setState) { state, action in
            state = action.payload
        })]
        super.init(initialState: initialState, reducers: reducers)
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

     When a `Selector` is overriden it will always give the same value.

     - Parameter selector: The `Selector` to override
     - Parameter value: The value the `Selector` should give
     */
    public func overrideSelector<Value>(_ selector: Selector<State, Value>, value: Value) {
        selector.mockResult(value: value)
    }
}
