/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import FluxorTestSupport
import XCTest

// swiftlint:disable force_cast

class TestInterceptorTests: XCTestCase {
    private let action1 = ActionTemplate(id: "Action1").createAction()
    private let oldState1 = TestState(counter: 1)
    private let newState1 = TestState(counter: 11)
    private let action2 = ActionTemplate(id: "Action2").createAction()
    private let oldState2 = TestState(counter: 2)
    private let newState2 = TestState(counter: 22)

    /// Is the dispatched `Action`, the `oldState` and the `newState` saved correctly?
    func testActionDispatched() {
        // Given
        let interceptor = TestInterceptor<TestState>()
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

    func testWaitEarlyExit() throws {
        // Given
        let interceptor = TestInterceptor<TestState>()
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        try interceptor.waitForActions(expectedNumberOfActions: 1, timeout: 0)
    }

    func testWaitFail() throws {
        // Given
        let interceptor = TestInterceptor<TestState>()
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        XCTAssertThrowsError(try interceptor.waitForActions(expectedNumberOfActions: 3, timeout: 1))
    }
}

private struct TestState: Equatable {
    let counter: Int
}
