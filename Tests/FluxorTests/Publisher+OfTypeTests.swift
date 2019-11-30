//
//  Publisher+OfTypeTests.swift
//  FluxorTests
//
//  Created by Morten Bjerg Gregersen on 21/11/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine
import Fluxor
import XCTest

class PublisherOfTypeTests: XCTestCase {
    var actions: PassthroughSubject<Action, Never>!

    override func setUp() {
        super.setUp()
        actions = .init()
    }

    func testMatchingType() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = actions
            .ofType(Action1.self)
            .sink { _ in
                expectation.fulfill()
            }
        // When
        actions.send(Action1())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    func testNonMatchingType() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.isInverted = true
        let cancellable = actions
            .ofType(Action2.self)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(Action1())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }
}

struct Action1: Action {}
struct Action2: Action {}
