/**
 * AnyCodableTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import XCTest

class AnyCodableEquatableTests: XCTestCase {
    /// Can all simple types be compared?
    func testEquality() throws {
        // Given
        let array: AnyCodable = [1, 2, 3]
        let dictionary: AnyCodable = ["a": 1, "b": 2, "c": 3]
        let values: [AnyCodable] = [
            nil,
            true,
            AnyCodable(1 as Int),
            AnyCodable(2 as Int8),
            AnyCodable(3 as Int16),
            AnyCodable(4 as Int32),
            AnyCodable(5 as Int64),
            AnyCodable(1 as UInt),
            AnyCodable(2 as UInt8),
            AnyCodable(3 as UInt16),
            AnyCodable(4 as UInt32),
            AnyCodable(5 as UInt64),
            AnyCodable(3.14159265358979323846 as Float),
            AnyCodable(3.14159265358979323846 as Double),
            "string",
            array,
            dictionary
        ]
        // Then
        values.forEach { XCTAssertEqual($0, $0) }
        XCTAssertNotEqual(values[3], values[10])
    }

    /// Can all nested dictionary and arrays be compared?
    func testNestedEquality() throws {
        // Given
        let dictionaryLiteral: AnyCodable = ["userInfo": ["things": ["nothing", "something", "anything"]],
                                             "userInfo": 42]
        let dictionary = AnyCodable(["userInfo": ["things": ["nothing", "something", "anything"]]])
        // Then
        XCTAssertEqual(dictionaryLiteral, dictionary)
    }
}
