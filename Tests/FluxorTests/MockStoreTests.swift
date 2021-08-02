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
        XCTAssertEqual(store.selectCurrent(selector), value)

        // Given
        let expectation1 = XCTestExpectation(description: #function)
        expectation1.expectedFulfillmentCount = 2
        let cancellable1 = store.select(selector).sink {
            if $0 == value {
                expectation1.fulfill()
            }
        }
        // When
        store.setState(newState: TestState(counter: 123))
        // Then
        XCTAssertEqual(store.selectCurrent(selector), value)
        wait(for: [expectation1], timeout: 5)
        cancellable1.cancel()

        // Given
        let newValue = 42
        store.resetOverriddenSelectors()
        let expectation2 = XCTestExpectation(description: #function)
        expectation2.expectedFulfillmentCount = 1
        let cancellable2 = store.select(selector).sink {
            if $0 == newValue {
                expectation2.fulfill()
            }
        }
        // When
        store.setState(newState: TestState(counter: newValue))
        // Then
        XCTAssertEqual(store.selectCurrent(selector), newValue)
        wait(for: [expectation2], timeout: 5)
        XCTAssertNotNil(cancellable2)
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

    private struct TestState: Equatable {
        var counter: Int
    }

    private struct TestAction: Action, Equatable {
        let increment: Int
    }
}
