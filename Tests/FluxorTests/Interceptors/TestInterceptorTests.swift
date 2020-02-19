/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

class TestInterceptorTests: XCTestCase {
    func testActionDispatched() {
        // Given
        let interceptor = TestInterceptor<TestState>()
        let action1 = createActionCreator(id: "Action1").createAction()
        let oldState1 = TestState(counter: 1)
        let newState1 = TestState(counter: 11)
        let action2 = createActionCreator(id: "Action2").createAction()
        let oldState2 = TestState(counter: 2)
        let newState2 = TestState(counter: 22)
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        let first = interceptor.dispatchedActionsAndStates[0]
        guard let firstAction = first.action as? AnonymousAction else { XCTFail("Invalid action"); return }
        XCTAssertEqual(firstAction, action1)
        XCTAssertEqual(first.oldState, oldState1)
        XCTAssertEqual(first.newState, newState1)
        let second = interceptor.dispatchedActionsAndStates[1]
        guard let secondAction = second.action as? AnonymousAction else { XCTFail("Invalid action"); return }
        XCTAssertEqual(secondAction, action2)
        XCTAssertEqual(second.oldState, oldState2)
        XCTAssertEqual(second.newState, newState2)
    }
}

private struct TestState: Equatable {
    let counter: Int
}