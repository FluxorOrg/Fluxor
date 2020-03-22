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
        var state = TestState(counter: 42)
        let incrementActionCreator = createActionCreator(id: "Increment", payloadType: Int.self)
        let incrementAction = incrementActionCreator.createAction(payload: 42)
        let expectation = XCTestExpectation(description: debugDescription)
        let reducer: Reducer<TestState> = createReducer { state, action in
            if let anonymousAction = action as? AnonymousAction,
                let theIncrementAction = anonymousAction.asCreated(by: incrementActionCreator) {
                state.counter = 1337
                XCTAssertEqual(theIncrementAction, incrementAction)
                expectation.fulfill()
            }
        }
        // When
        reducer.reduce(&state, incrementAction)
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(state, TestState(counter: 1337))
    }

    private struct TestState: Equatable {
        var counter: Int
    }
}
