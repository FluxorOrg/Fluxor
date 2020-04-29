//
//  File.swift
//
//
//  Created by Morten Bjerg Gregersen on 04/01/2020.
//

import Combine
import Fluxor
import XCTest

class ActionPublisherWithIdentifierTests: XCTestCase {
    var actions: PassthroughSubject<Action, Never>!
    let action1Identifier = "TestAction"
    let action2Identifier = "OtherTestAction"
    lazy var actionTemplate1 = ActionTemplate(id: action1Identifier)
    lazy var action1 = actionTemplate1.createAction()

    override func setUp() {
        super.setUp()
        actions = .init()
    }

    /// Does the operator let the `Action` pass if the identifier matches?
    func testMatchingIdentifier() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = actions
            .withIdentifier(action1Identifier)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(action1)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }

    /// Does the operator block the `Action` if the identifier doesn't match?
    func testNonMatchingIdentifier() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.isInverted = true
        let cancellable = actions
            .withIdentifier(action2Identifier)
            .sink { _ in expectation.fulfill() }
        // When
        actions.send(action1)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }
}
