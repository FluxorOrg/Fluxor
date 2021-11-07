/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import Foundation
#if canImport(Combine)
    import Combine
    import XCTest
#else
    import OpenCombine
    import XCTest
#endif

public func XCTAssertEqual(_ expression1: @autoclosure () -> Action,
                           _ expression2: @autoclosure () -> Action,
                           _: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line)
{
    guard let action1 = expression1() as? EncodableAction else {
        return XCTFail("The first Action is not Encodable and can't be compared", file: file, line: line)
    }
    guard let action2 = expression2() as? EncodableAction else {
        return XCTFail("The second Action is not Encodable and can't be compared", file: file, line: line)
    }
    let jsonEncoder = JSONEncoder()
    guard let action1JsonData = action1.encode(with: jsonEncoder),
          let action1Json = String(data: action1Json, encoding: .utf8),
          let action2JsonData = action2.encode(with: jsonEncoder),
          let action2Json = String(data: action2Json, encoding: .utf8)
    else {
        return XCTFail("An error occurred while encoding the action.", file: file, line: line)
    }
    guard action1Json == action2Json else {
        return XCTFail("\"\(action1Json)\" is not equal to \"\(action2Json)\"", file: file, line: line)
    }
}

// swiftlint:disable large_tuple

/**
 A `MockStore` is intended to be used in unit tests where you want to observe
 which `Action`s are dispatched and manipulate the `State` and `Selector`s.
 */
public class MockStore<State, Environment>: Store<State, Environment> {
    /// All the `Action`s and state changes that has happened.
    public var stateChanges: [(action: Action, oldState: State, newState: State)] {
        testInterceptor.stateChanges
    }

    /// All the `Action`s that has been dispatched.
    public var dispatchedActions: [Action] {
        stateChanges.map(\.action)
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
    override public init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        let reducers = reducers + [Reducer(ReduceOn(setState) { state, action in state = action.payload })]
        super.init(initialState: initialState, environment: environment, reducers: reducers)
        super.register(interceptor: testInterceptor)
    }

    /**
     Sets a new `State` on the `Store`.

     - Parameter newState: The new `State` to set on the `Store`
     */
    public func setState(newState: State) {
        dispatch(action: setState(payload: newState))
    }

    /**
     Overrides the `Selector` with a 'default' value.

     When a `Selector` is overriden it will always give the same value when used to select from this `MockStore`.

     - Parameter selector: The `Selector` to override
     - Parameter value: The value the `Selector` should give when selecting
     */
    public func overrideSelector<Value>(_ selector: Fluxor.Selector<State, Value>, value: Value) {
        overridenSelectorValues[selector.id] = value
    }

    /**
     Resets all overridden `Selector`s on this `MockStore`.
     */
    public func resetOverriddenSelectors() {
        overridenSelectorValues.removeAll()
    }

    override public func select<Value>(_ selector: Fluxor.Selector<State, Value>) -> AnyPublisher<Value, Never> {
        guard let value = overridenSelectorValues[selector.id] as? Value else { return super.select(selector) }
        return $state.map { _ in value }.eraseToAnyPublisher()
    }

    override public func selectCurrent<Value>(_ selector: Fluxor.Selector<State, Value>) -> Value {
        overridenSelectorValues[selector.id] as? Value ?? super.selectCurrent(selector)
    }
}
