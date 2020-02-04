/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

class ActionTests: XCTestCase {
    /// Is it possible to encode an `Action`?
    func testEncoding() {
        // Given
        let action = TestAction(increment: 42)
        let encoder = JSONEncoder()
        // When
        let data = action.encode(with: encoder)!
        let json = String(data: data, encoding: .utf8)!
        // Then
        XCTAssertEqual(json, #"{"increment":42}"#)
    }

    func testCreateActionCreator() {
        // Given
        let actionCreator = createActionCreator(id: "something")
        // When
        let action = actionCreator.create()
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
    }
    
    func testCreateActionCreatorWithPayload() {
        // Given
        let actionCreator = createActionCreator(id: "something", payloadType: Int.self)
        let payload = 42
        // When
        let action = actionCreator.create(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(action.payload, payload)
    }
}

private struct TestAction: Action {
    let increment: Int
}
