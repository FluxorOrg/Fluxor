/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

// swiftlint:disable line_length

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

    /// Is it possible to create an `ActionCreator` without payload type?
    func testCreateActionCreator() {
        // Given
        let actionCreator = createActionCreator(id: "something")
        // When
        let action = actionCreator.createAction()
        // Then
        XCTAssertTrue(action.wasCreated(by: actionCreator))
        XCTAssertEqual(json(from: action), #"{"id":"something"}"#)
    }

    /// Is it possible to create an `ActionCreator` with an encodable payload type?
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

    /// Is it possible to create an `ActionCreator` with a custom payload type?
    func testCreateActionCreatorWithCustomPayload() {
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
        // swiftlint:disable:next line_length
        XCTAssertEqual(json(from: action), #"{"id":"something","payload":{"address":"1 Infinite Loop","age":56,"name":"Steve Jobs"}}"#)
    }

    /// Is it possible to create an `ActionCreator` with a tuple payload type?
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

    /// Is it possible to cast an `AnonymousAction` as if it was created by an `ActionCreator` without payload type?
    func testAsCreatedByActionCreatorWithoutPayload() {
        // Given
        let id = "something"
        let actionCreator = createActionCreator(id: id)
        let action: AnonymousAction = actionCreator.createAction()
        // When
        let castAction = action.asCreated(by: actionCreator)
        // Then
        XCTAssertEqual(castAction?.id, id)

        // When
        let otherActionCreator = createActionCreator(id: "other thing")
        // Then
        XCTAssertNil(action.asCreated(by: otherActionCreator))
    }

    /// Is it possible to cast an `AnonymousAction` as if it was created by an `ActionCreator` with an encodable payload type?
    func testAsCreatedByActionCreatorWithEncodablePayload() {
        // Given
        let id = "something"
        let payload = 42
        let actionCreator = createActionCreator(id: id, payloadType: Int.self)
        let action: AnonymousAction = actionCreator.createAction(payload: payload)
        // When
        let castAction = action.asCreated(by: actionCreator)
        // Then
        XCTAssertEqual(castAction?.id, id)
        XCTAssertEqual(castAction?.payload, payload)

        // When
        let otherActionCreator = createActionCreator(id: "other thing", payloadType: String.self)
        // Then
        XCTAssertNil(action.asCreated(by: otherActionCreator))
    }

    /// Is it possible to cast an `AnonymousAction` as if it was created by an `ActionCreator` with a custom payload type?
    func testAsCreatedByActionCreatorWithCustomPayload() {
        // Given
        let id = "something"
        let payload = Person(name: "Steve Jobs", address: "1 Infinite Loop", age: 56)
        let actionCreator = createActionCreator(id: id, payloadType: Person.self)
        let action: AnonymousAction = actionCreator.createAction(payload: payload)
        // When
        let castAction = action.asCreated(by: actionCreator)
        // Then
        XCTAssertEqual(castAction?.id, id)
        XCTAssertEqual(castAction?.payload, payload)

        // When
        let otherActionCreator = createActionCreator(id: "other thing", payloadType: (name: String, age: Int).self)
        // Then
        XCTAssertNil(action.asCreated(by: otherActionCreator))
    }

    /// Is it possible to cast an `AnonymousAction` as if it was created by an `ActionCreator` with a tuple payload type?
    func testAsCreatedByActionCreatorWithTuplePayload() {
        // Given
        let id = "something"
        let payload = (count: 42, name: "Steve")
        let actionCreator = createActionCreator(id: id, payloadType: (count: Int, name: String).self)
        let action: AnonymousAction = actionCreator.createAction(payload: payload)
        // When
        let castAction = action.asCreated(by: actionCreator)
        // Then
        XCTAssertEqual(castAction?.id, id)
        XCTAssertEqual(castAction?.payload.count, payload.count)
        XCTAssertEqual(castAction?.payload.name, payload.name)

        // When
        let otherActionCreator = createActionCreator(id: "other thing", payloadType: (name: String, age: Int).self)
        // Then
        XCTAssertNil(action.asCreated(by: otherActionCreator))
    }

    private struct Person: Equatable {
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
