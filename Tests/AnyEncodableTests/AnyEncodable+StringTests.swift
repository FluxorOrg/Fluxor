/**
 * AnyEncodableTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyEncodable
import XCTest

class AnyEncodableStringTests: XCTestCase {
    /// Can all simple types be compared?
    func testNilDescription() {
        // Given
        let value: Any = ()
        let encodable = AnyEncodable(value)
        // Then
        XCTAssertEqual(encodable.description, "nil")
        XCTAssertEqual(encodable.debugDescription, "AnyEncodable(nil)")
    }

    func testNoDescription() {
        // Given
        let value = Nothing()
        let encodable = AnyEncodable(value)
        // Then
        XCTAssertEqual(encodable.description, "Nothing()")
        XCTAssertEqual(encodable.debugDescription, "AnyEncodable(Nothing())")
    }

    func testCustomDescription() {
        // Given
        let value = Anything()
        let encodable = AnyEncodable(value)
        // Then
        XCTAssertEqual(encodable.description, value.description)
        XCTAssertEqual(encodable.debugDescription, "AnyEncodable(\(value.debugDescription))")
    }
}

private struct Anything: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String { "Some description" }
    var debugDescription: String { "Some debug description" }
}

private struct Nothing {}
