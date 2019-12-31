//
//  File.swift
//  FluxorTests
//
//  Created by Morten Bjerg Gregersen on 31/12/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

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
