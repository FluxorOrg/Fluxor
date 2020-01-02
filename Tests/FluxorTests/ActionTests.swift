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
}

private struct TestAction: Action {
    let increment: Int
}
