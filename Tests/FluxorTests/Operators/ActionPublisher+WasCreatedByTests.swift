/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import OpenCombineShim
import Fluxor
import XCTest

class ActionPublisherWasCreatedByTests: XCTestCase {
    var actions: PassthroughSubject<Action, Never>!
    let template1 = ActionTemplate(id: "Action1")
    let template2 = ActionTemplate(id: "Action2")

    override func setUp() {
        super.setUp()
        actions = .init()
    }

    /// Does the operator let the `Action` pass if it matches?
    func testMatchingTemplate() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = actions
            .wasCreated(from: template1)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(template1.createAction())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    /// Does the operator block the `Action` if it doesn't match?
    func testNonMatchingTemplate() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.isInverted = true
        let cancellable = actions
            .wasCreated(from: template2)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(template1.createAction())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }
}
