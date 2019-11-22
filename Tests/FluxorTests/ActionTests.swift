//
//  ActionTests.swift
//  FluxorTests
//
//  Created by Morten Bjerg Gregersen on 21/11/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Fluxor
import XCTest

class ActionTests: XCTestCase {
    func testEncodablePayload() {
        XCTAssertNil(EmptyAction().encodablePayload)
    }
}

struct EmptyAction: Action {}
