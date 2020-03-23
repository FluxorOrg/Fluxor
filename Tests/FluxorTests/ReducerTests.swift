//
//  File.swift
//
//
//  Created by Morten Bjerg Gregersen on 29/02/2020.
//

import Fluxor
import XCTest

class ReducerTests: XCTestCase {
    func testCreateReducerClosure() {
        // Given
        var state = TestState(counter: 1337)
        let incrementActionCreator = createActionCreator(id: "Increment", payloadType: Int.self)
        let incrementAction = incrementActionCreator.createAction(payload: 42)
        let expectation = XCTestExpectation(description: debugDescription)
        let reducer: Reducer<TestState> = createReducer { state, action in
            if let anonymousAction = action as? AnonymousAction,
                let action = anonymousAction.asCreated(by: incrementActionCreator) {
                state.counter = state.counter + action.payload
                XCTAssertEqual(action, incrementAction)
                expectation.fulfill()
            }
        }
        // When
        reducer.reduce(&state, incrementAction)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1379))
    }

    func testCreateReducerOnActionType() {
        // Given
        var state = TestState(counter: 1337)
        let incrementAction = IncrementAction(increment: 42)
        let decrementActionCreator = createActionCreator(id: "Decrement", payloadType: Int.self)
        let decrementAction = decrementActionCreator.createAction(payload: 1)
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 2
        let reducer: Reducer<TestState> = createReducer(
            reduceOn(IncrementAction.self) { state, action in
                state.counter = state.counter + action.increment
                XCTAssertEqual(action, incrementAction)
                expectation.fulfill()
            },
            reduceOn(decrementActionCreator) { state, action in
                state.counter = state.counter - action.payload
                XCTAssertEqual(action, decrementAction)
                expectation.fulfill()
            }
        )
        // When
        reducer.reduce(&state, incrementAction)
        reducer.reduce(&state, decrementAction)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1378))
    }

    private struct TestState: Equatable {
        var counter: Int
    }

    private struct IncrementAction: Action, Equatable {
        let increment: Int
    }
}
