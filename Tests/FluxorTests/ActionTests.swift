/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

class ActionTests: XCTestCase {
    func testEncoding() {
        let action = TestAction(increment: 42)
        let encoder = JSONEncoder()
        let data = action.encode(with: encoder)!
        let json = String(data: data, encoding: .utf8)!
        XCTAssertEqual(json, #"{"increment":42}"#)
    }
}

private struct TestAction: Action {
    let increment: Int
}
