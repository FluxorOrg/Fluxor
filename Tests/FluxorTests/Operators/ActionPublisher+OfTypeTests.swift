/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
#if canImport(Combine)
import Combine
#else
import OpenCombine
#endif
import XCTest

class ActionPublisherOfTypeTests: XCTestCase {
    var actions: PassthroughSubject<Action, Never>!

    override func setUp() {
        super.setUp()
        actions = .init()
    }

    /// Does the operator let the `Action` pass if it matches?
    func testMatchingType() {
        // Given
        let expectation = XCTestExpectation(description: #function)
        let cancellable = actions
            .ofType(Action1.self)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(Action1())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    /// Does the operator block the `Action` if it doesn't match?
    func testNonMatchingType() {
        // Given
        let expectation = XCTestExpectation(description: #function)
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

    private struct Action1: Action {}
    private struct Action2: Action {}
}
