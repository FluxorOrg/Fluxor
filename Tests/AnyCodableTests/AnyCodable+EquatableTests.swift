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
        let array = [1, 2, 3].map(AnyCodable.init)
        let dictionary = ["a": 1, "b": 2, "c": 3].mapValues(AnyCodable.init)
        let values = [nil, true,
                      1 as Int, 2 as Int8, 3 as Int16, 4 as Int32, 5 as Int64,
                      1 as UInt, 2 as UInt8, 3 as UInt16, 4 as UInt32, 5 as UInt64,
                      3.14159265358979323846 as Float, 3.14159265358979323846 as Double,
                      "string", array, dictionary].map(AnyCodable.init)
        // Then
        values.forEach { XCTAssertEqual($0, $0) }
        XCTAssertNotEqual(values[3], values[10])
    }
}
