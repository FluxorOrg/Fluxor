/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

class PrintStoreInterceptorTests: XCTestCase {
    func testActionDispatched() {
        // Given
        var printedStrings = [String]()
        let interceptor = PrintStoreInterceptor<TestState> { printedStrings.append($0) }
        let action1 = TestAction()
        let oldState1 = TestState(counter: 1)
        let newState1 = TestState(counter: 11)
        let action2 = createActionCreator(id: "Action2", payloadType: Int.self).createAction(payload: 42)
        let oldState2 = TestState(counter: 2)
        let newState2 = TestState(counter: 22)
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        XCTAssertEqual(printedStrings[0], "PrintStoreInterceptor<TestState> - action dispatched: TestAction")
        XCTAssertEqual(printedStrings[1], #"PrintStoreInterceptor<TestState> - state changed to: {"counter":11}"#)
        XCTAssertEqual(printedStrings[2], #"PrintStoreInterceptor<TestState> - action dispatched: AnonymousActionWithPayload<Int>, data: {"id":"Action2","payload":42}"#)
        XCTAssertEqual(printedStrings[3], #"PrintStoreInterceptor<TestState> - state changed to: {"counter":22}"#)
    }
}

private struct TestAction: Action {}

private struct TestState: Encodable {
    let counter: Int
}
