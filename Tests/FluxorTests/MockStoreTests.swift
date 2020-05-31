/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import FluxorTestSupport
import XCTest

// swiftlint:disable force_cast

class MockStoreTests: XCTestCase {
    private var store: MockStore<TestState, Void>!
    private let initialState = TestState(counter: 0)

    override func setUp() {
        super.setUp()
        store = MockStore(initialState: initialState)
    }

    /// Can the state be set?
    func testSetState() {
        // Given
        XCTAssertEqual(store.state, initialState)
        let initialStateHash = store.stateHash
        // When
        let newState = TestState(counter: 42)
        store.setState(newState: newState)
        // Then
        XCTAssertEqual(store.state, newState)
        XCTAssertNotEqual(store.stateHash, initialStateHash)
    }

    /// Can the selector be overridden?
    func testOverrideSelector() {
        // Given
        let selector = Selector(keyPath: \TestState.counter)
        let value = 1337
        // When
        store.overrideSelector(selector, value: value)
        // Then
        XCTAssertEqual(selector.result?.value, value)
        XCTAssertNil(selector.result?.stateHash)
        XCTAssertEqual(store.selectCurrent(selector), value)

        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 2
        let cancellable = store.select(selector).sink {
            if $0 == value {
                expectation.fulfill()
            }
        }
        // When
        store.setState(newState: TestState(counter: 123))
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }

    /// Can we get all state changes in a `MockStore`?
    func testMockStoreStateChanges() {
        // Given
        let mockStore = MockStore(initialState: TestState(counter: 0))
        let action = TestAction(increment: 1)
        let modifiedState = TestState(counter: 2)
        // When
        mockStore.dispatch(action: action)
        mockStore.setState(newState: modifiedState)
        // Then
        XCTAssertEqual(mockStore.stateChanges.count, 2)
        XCTAssertEqual(mockStore.stateChanges[0].action as! TestAction, action)
        let setStateAction = mockStore.stateChanges[1].action as! AnonymousAction<TestState>
        XCTAssertEqual(setStateAction.id, "Set State")
        XCTAssertEqual(mockStore.stateChanges[1].newState, modifiedState)
    }

    private struct TestState: Encodable, Equatable {
        var counter: Int
    }

    private struct TestAction: Action, Equatable {
        let increment: Int
    }
}
