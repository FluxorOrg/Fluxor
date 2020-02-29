//
//  File.swift
//
//
//  Created by Morten Bjerg Gregersen on 29/02/2020.
//

import Fluxor
import XCTest

class ReducerTests: XCTestCase {
    func testCreateReducer() {
        // Given
        let incrementAction = TestAction(increment: 123)
        let initialState = TestState()
        let expectation = XCTestExpectation(description: debugDescription)
        let reducer = createReducer { state, action -> TestState in
            var state = state
            state.counter = 1337
            // swiftlint:disable:next force_cast
            XCTAssertEqual(action as! TestAction, incrementAction)
            expectation.fulfill()
            return state
        }
        // When
        let newState = reducer.reduce(initialState, incrementAction)
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(newState, TestState(counter: 1337))
    }

    private struct TestAction: Action, Equatable {
        let increment: Int
    }

    private struct TestState: Equatable {
        var counter = 42
    }
}
