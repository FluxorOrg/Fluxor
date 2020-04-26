/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import XCTest

class ActionPublisherWasCreatedByTests: XCTestCase {
    var actions: PassthroughSubject<Action, Never>!
    let creator1 = ActionCreator.create(id: "Action1")
    let creator2 = ActionCreator.create(id: "Action2")

    override func setUp() {
        super.setUp()
        actions = .init()
    }

    /// Does the operator let the `Action` pass if it matches?
    func testMatchingCreator() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)

        let cancellable = actions
            .wasCreated(by: creator1)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(creator1.createAction())
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }

    /// Does the operator block the `Action` if it doesn't match?
    func testNonMatchingCreator() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.isInverted = true
        let cancellable = actions
            .wasCreated(by: creator2)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(creator1.createAction())
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }
}
