/**
 * AnyCodableTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import XCTest

class AnyCodableStringTests: XCTestCase {
    /// Can all simple types be compared?
    func testNilDescription() {
        // Given
        let value: Any = ()
        let encodable = AnyCodable(value)
        // Then
        XCTAssertEqual(encodable.description, "nil")
        XCTAssertEqual(encodable.debugDescription, "AnyCodable(nil)")
    }

    func testNoDescription() {
        // Given
        let value = Nothing()
        let encodable = AnyCodable(value)
        // Then
        XCTAssertEqual(encodable.description, "Nothing()")
        XCTAssertEqual(encodable.debugDescription, "AnyCodable(Nothing())")
    }

    func testCustomDescription() {
        // Given
        let value = Anything()
        let encodable = AnyCodable(value)
        // Then
        XCTAssertEqual(encodable.description, value.description)
        XCTAssertEqual(encodable.debugDescription, "AnyCodable(\(value.debugDescription))")
    }
}

private struct Anything: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String { "Some description" }
    var debugDescription: String { "Some debug description" }
}

private struct Nothing {}
