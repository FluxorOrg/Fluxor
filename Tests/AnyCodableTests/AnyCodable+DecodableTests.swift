/**
 * AnyCodableTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import XCTest

// swiftlint:disable force_cast

class AnyCodableDecodableTests: XCTestCase {
    /// Can all simple types be decoded?
    func testDecoding() throws {
        // Given
        let json = """
        {
          "array" : [1, 2, 3, 4],
          "boolean" : true,
          "double" : 3.1415926535897931,
          "integer" : -1,
          "nested" : {
            "a" : "alpha",
            "b" : "bravo",
            "c" : "charlie"
          },
          "string" : "string",
          "void" : null
        }
        """
        let dictionary: [String: AnyCodable] = [
            "void": nil,
            "boolean": true,
            "integer": -1,
            "double": 3.14159265358979323846,
            "string": "string"
        ]
        // When
        let decoder = JSONDecoder()
        let decodedDictionary = try decoder.decode([String: AnyCodable].self, from: json.data(using: .utf8)!)
        // Then
        ["void", "boolean", "integer", "double", "string"].forEach { key in
            XCTAssertEqual(decodedDictionary[key]!, dictionary[key]!)
        }
        XCTAssertEqual((decodedDictionary["array"]!.value as! [Any]).count, 4)
        XCTAssertEqual((decodedDictionary["nested"]!.value as! [String: Any]).count, 3)
    }
}

private struct Something: Equatable {
    let isNothing: Bool
}
