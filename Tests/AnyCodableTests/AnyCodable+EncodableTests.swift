/**
 * AnyCodableTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import XCTest

// swiftlint:disable force_cast function_body_length

class AnyCodableEncodableTests: XCTestCase {
    /// Can all simple types be encoded?
    func testSimpleTypes() throws {
        // Given
        let dictionary: [String: AnyCodable] = [
            "void": nil,
            "boolean": true,
            "integer": 1,
            "float": AnyCodable(3.14159265358979323846 as Float),
            "double": 3.14159265358979323846,
            "string": "string",
            "date": AnyCodable(Date(timeIntervalSince1970: 1585778827)),
            "url": AnyCodable(URL(string: "https://apple.com")!),
            "arraySigned": [1 as Int8, 2 as Int16, 3 as Int32, 4 as Int64],
            "arrayUnsigned": [0 as UInt, 1 as UInt8, 2 as UInt16, 3 as UInt32, 4 as UInt64],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            ],
            "custom": AnyCodable(CustomEncodable(value: 42))
        ]
        // When
        let encoder = JSONEncoder()
        var outputFormatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .sortedKeys]
        var encodedUrl: String = "https:\\/\\/apple.com"
        #if swift(>=5.3)
        outputFormatting = outputFormatting.union(.withoutEscapingSlashes)
        encodedUrl = "https://apple.com"
        #endif
        encoder.outputFormatting = outputFormatting
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(dictionary)
        let json = String(data: data, encoding: .utf8)
        // Then
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) // On Linux float and double are encoded different
        let expected = """
        {
          "arraySigned" : [
            1,
            2,
            3,
            4
          ],
          "arrayUnsigned" : [
            0,
            1,
            2,
            3,
            4
          ],
          "boolean" : true,
          "custom" : {
            "value" : 42
          },
          "date" : 1585778827,
          "double" : 3.1415926535897931,
          "float" : 3.1415927410125732,
          "integer" : 1,
          "nested" : {
            "a" : "alpha",
            "b" : "bravo",
            "c" : "charlie"
          },
          "string" : "string",
          "url" : "\(encodedUrl)",
          "void" : null
        }
        """
        #else
        let expected = """
        {
          "arraySigned" : [
            1,
            2,
            3,
            4
          ],
          "arrayUnsigned" : [
            0,
            1,
            2,
            3,
            4
          ],
          "boolean" : true,
          "custom" : {
            "value" : 42
          },
          "date" : 1585778827,
          "double" : 3.141592653589793,
          "float" : 3.1415927,
          "integer" : 1,
          "nested" : {
            "a" : "alpha",
            "b" : "bravo",
            "c" : "charlie"
          },
          "string" : "string",
          "url" : "\(encodedUrl)",
          "void" : null
        }
        """
        #endif
        XCTAssertEqual(json, expected)
    }

    /// Does an error get thrown when the value can't be encoded?
    func testInvalidValue() {
        // Given
        let value = Something(isNothing: true)
        let invalidType = AnyCodable(value)
        // When
        let encoder = JSONEncoder()
        XCTAssertThrowsError(try encoder.encode(invalidType), "Boom") { error in
            // Then
            let encodingError = error as! EncodingError
            guard case .invalidValue(let errorValue, let context) = encodingError else {
                XCTFail("Wrong error type"); return
            }
            XCTAssertEqual(errorValue as! Something, value)
            XCTAssertEqual(context.codingPath.count, 0)
            XCTAssertEqual(context.debugDescription, "Value cannot be encoded")
        }
    }
}

private struct Something: Equatable {
    let isNothing: Bool
}

private struct CustomEncodable: Encodable {
    let value: Int
}
