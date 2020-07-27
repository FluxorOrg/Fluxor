/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

// swiftlint:disable force_try function_body_length

class PrintInterceptorTests: XCTestCase {
    /// Is the dispatched `Action`, the `oldState` and the `newState` printed correctly?
    func testActionDispatchedWithoutEncodablePayload() {
        // Given
        var printedStrings = [String]()
        let interceptor = PrintInterceptor<TestState> { printedStrings.append($0) }
        let action1 = EmptyAction()
        let oldState1 = TestState(counter: 1)
        let newState1 = TestState(counter: 11)
        let action2 = ActionTemplate(id: "Action2", payloadType: UnencodablePayload.self)
            .createAction(payload: UnencodablePayload(increment: 13))
        let oldState2 = newState1
        let newState2 = TestState(counter: 22)
        let action3 = ActionWithUnencodablePayload(increment: 22)
        let oldState3 = newState2
        let newState3 = TestState(counter: 33)
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        interceptor.actionDispatched(action: action3, oldState: oldState3, newState: newState3)
        // Then
        XCTAssertEqual(printedStrings[0], "PrintInterceptor<TestState> - action dispatched: EmptyAction")
        XCTAssertEqual(printedStrings[1], """
        PrintInterceptor<TestState> - state changed to: {
          "counter" : 11
        }
        """)
        XCTAssertEqual(printedStrings[2], """
        PrintInterceptor<TestState> - action dispatched: AnonymousAction<UnencodablePayload>, data: {
          "id" : "Action2",
          "payload" : {
            "increment" : 13
          }
        }
        """)
        XCTAssertEqual(printedStrings[3], """
        PrintInterceptor<TestState> - state changed to: {
          "counter" : 22
        }
        """)
        XCTAssertEqual(printedStrings[4], """
        PrintInterceptor<TestState> - action dispatched: ActionWithUnencodablePayload
        ⚠️ The payload of the Action has properties but aren't Encodable. Make it Encodable to get them printed.
        """)
        XCTAssertEqual(printedStrings[5], """
        PrintInterceptor<TestState> - state changed to: {
          "counter" : 33
        }
        """)
    }

    /// Is the dispatched `Action`, the `oldState` and the `newState` printed correctly?
    func testActionDispatchedWithEncodablePayload() {
        // Given
        var printedStrings = [String]()
        let interceptor = PrintInterceptor<TestState> { printedStrings.append($0) }
        let action1 = ActionWithEncodablePayload(increment: 2)
        let oldState1 = TestState(counter: 1)
        let newState1 = TestState(counter: 11)
        let action2 = ActionTemplate(id: "Action2", payloadType: EncodablePayload.self)
            .createAction(payload: .init(increment: 3))
        let oldState2 = newState1
        let newState2 = TestState(counter: 22)
        _ = try! JSONEncoder().encode(AnonymousAction(id: "Bla", payload: EncodablePayload(increment: 1)))
        // When
        interceptor.actionDispatched(action: action1, oldState: oldState1, newState: newState1)
        interceptor.actionDispatched(action: action2, oldState: oldState2, newState: newState2)
        // Then
        XCTAssertEqual(printedStrings[0], """
        PrintInterceptor<TestState> - action dispatched: ActionWithEncodablePayload, data: {
          "increment" : 2
        }
        """)
        XCTAssertEqual(printedStrings[1], """
        PrintInterceptor<TestState> - state changed to: {
          "counter" : 11
        }
        """)
        XCTAssertEqual(printedStrings[2], """
        PrintInterceptor<TestState> - action dispatched: AnonymousAction<EncodablePayload>, data: {
          "id" : "Action2",
          "payload" : {
            "increment" : 3
          }
        }
        """)
        XCTAssertEqual(printedStrings[3], """
        PrintInterceptor<TestState> - state changed to: {
          "counter" : 22
        }
        """)
    }

    /// Only here for test coverage of the public initializer.
    func testPublicInit() {
        // Given
        let interceptor = PrintInterceptor<TestState>()
        let action = EmptyAction()
        let oldState = TestState(counter: 1)
        let newState = TestState(counter: 11)
        // When
        interceptor.actionDispatched(action: action, oldState: oldState, newState: newState)
        // Then
        XCTAssertNotNil(interceptor)
    }
}

private struct EmptyAction: Action {}

private struct ActionWithUnencodablePayload: Action {
    let increment: Int
}

private struct UnencodablePayload {
    let increment: Int
}

private struct ActionWithEncodablePayload: EncodableAction {
    let increment: Int
}

private struct EncodablePayload: Encodable {
    let increment: Int
}

private struct TestState: Encodable {
    let counter: Int
}
