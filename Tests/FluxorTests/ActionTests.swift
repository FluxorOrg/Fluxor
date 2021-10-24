/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

class ActionTests: XCTestCase {
    /// Is it possible to encode an `EncodableAction`?
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

    /// Is it possible to create an `ActionTemplate` without payload type?
    func testCreateActionTemplate() {
        // Given
        let actionTemplate = ActionTemplate(id: "something")
        // When
        let action = actionTemplate.createAction()
        let actionFromFunction = actionTemplate()
        // Then
        XCTAssertTrue(action.wasCreated(from: actionTemplate))
        XCTAssertEqual(json(from: action), #"{"id":"something"}"#)
        XCTAssertEqual(action, actionFromFunction)
    }

    /// Is it possible to create an `ActionTemplate` with an encodable payload type?
    func testCreateActionTemplateWithEncodablePayload() {
        // Given
        let actionTemplate = ActionTemplate(id: "something", payloadType: Int.self)
        let payload = 42
        // When
        let action = actionTemplate.createAction(payload: payload)
        let actionFromFunction = actionTemplate(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(from: actionTemplate))
        XCTAssertEqual(action.payload, payload)
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":42}"#)
        XCTAssertEqual(action, actionFromFunction)
    }

    /// Is it possible to create an `ActionTemplate` with a custom payload type?
    func testCreateActionTemplateWithCustomPayload() {
        // Given
        let actionTemplate = ActionTemplate(id: "something", payloadType: Person.self)
        let payload = Person(name: "Steve Jobs", address: "1 Infinite Loop", age: 56)
        // When
        let action = actionTemplate.createAction(payload: payload)
        let actionFromFunction = actionTemplate(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(from: actionTemplate))
        XCTAssertEqual(action.payload.name, payload.name)
        XCTAssertEqual(action.payload.address, payload.address)
        XCTAssertEqual(action.payload.age, payload.age)
        // swiftlint:disable:next line_length
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":{"address":"1 Infinite Loop","age":56,"name":"Steve Jobs"}}"#)
        XCTAssertEqual(action, actionFromFunction)
    }

    /// Is it possible to create an `ActionTemplate` with a tuple payload type?
    func testCreateActionTemplateWithTuple() {
        // Given
        let actionTemplate = ActionTemplate(id: "something", payloadType: (increment: Int, String).self)
        let payload = (increment: 42, "Boom!")
        // When
        let action = actionTemplate.createAction(payload: payload)
        let actionFromFunction = actionTemplate(payload: payload)
        // Then
        XCTAssertTrue(action.wasCreated(from: actionTemplate))
        XCTAssertEqual(action.payload.increment, payload.increment)
        XCTAssertEqual(action.payload.1, payload.1)
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":{".1":"Boom!","increment":42}}"#)
        XCTAssertEqual(action, actionFromFunction)
    }

    private struct Person: Equatable {
        let name: String
        let address: String
        let age: Int
    }

    private struct TestAction: EncodableAction {
        let increment: Int
    }

    private func json<Payload>(from action: AnonymousAction<Payload>) -> String {
        // swiftlint:disable:next force_try
        let data = try! encoder.encode(action)
        return String(data: data, encoding: .utf8)!
    }

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
}
