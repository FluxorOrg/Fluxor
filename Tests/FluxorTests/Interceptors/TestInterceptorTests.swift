/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import FluxorTestSupport
import XCTest

// swiftlint:disable force_cast

class TestInterceptorTests: XCTestCase {
    /// Is the dispatched `Action`, the `oldState` and the `newState` saved correctly?
    func testActionDispatched() {
        // Given
        let interceptor = TestInterceptor<TestState>()
        let action1 = ActionTemplate(id: "Action1").createAction()
        let oldState1 = TestState(counter: 1)
        let newState1 = TestState(counter: 11)
        let action2 = ActionTemplate(id: "Action2").createAction()
        let oldState2 = TestState(counter: 2)
        let newState2 = TestState(counter: 22)
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        let first = interceptor.stateChanges[0]
        XCTAssertEqual((first.action as! AnonymousAction<Void>).id, action1.id)
        XCTAssertEqual(first.oldState, oldState1)
        XCTAssertEqual(first.newState, newState1)
        let second = interceptor.stateChanges[1]
        XCTAssertEqual((second.action as! AnonymousAction<Void>).id, action2.id)
        XCTAssertEqual(second.oldState, oldState2)
        XCTAssertEqual(second.newState, newState2)
    }
}

private struct TestState: Equatable {
    let counter: Int
}
