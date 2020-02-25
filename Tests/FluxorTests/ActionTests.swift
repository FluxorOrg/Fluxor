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
        let action = actionCreator.createAction()
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(json(from: action), #"{"id":"something"}"#)
    }
    
    func testCreateActionCreatorWithEncodablePayload() {
        // Given
        let actionCreator = createActionCreator(id: "something", payloadType: Int.self)
        let payload = 42
        // When
        let action = actionCreator.createAction(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(action.payload, payload)
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":42}"#)
    }

    func testCreateActionCreatorWithNonEncodablePayload() {
        // Given
        let actionCreator = createActionCreator(id: "something", payloadType: Person.self)
        let payload = Person(name: "Steve Jobs", address: "1 Infinite Loop", age: 56)
        // When
        let action = actionCreator.createAction(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(action.payload.name, payload.name)
        XCTAssertEqual(action.payload.address, payload.address)
        XCTAssertEqual(action.payload.age, payload.age)
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":{"address":"1 Infinite Loop","age":56,"name":"Steve Jobs"}}"#)
    }

    func testCreateActionCreatorWithTuple() {
        // Given
        let actionCreator = createActionCreator(id: "something", payloadType: (increment: Int, String).self)
        let payload = (increment: 42, "Boom!")
        // When
        let action = actionCreator.createAction(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(action.payload.increment, payload.increment)
        XCTAssertEqual(action.payload.1, payload.1)
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":{".1":"Boom!","increment":42}}"#)
    }

    private struct Person {
        let name: String
        let address: String
        let age: Int
    }

    private struct TestAction: Action {
        let increment: Int
    }

    private func json(from action: Action) -> String {
        let data = action.encode(with: encoder)!
        return String(data: data, encoding: .utf8)!
    }

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
}
