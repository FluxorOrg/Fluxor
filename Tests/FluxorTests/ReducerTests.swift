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
        let testAction = TestAction(increment: 42)
        let expectation = XCTestExpectation(description: debugDescription)
        let reducer: Reducer<TestState> = createReducer(
            reduceOn(TestAction.self) { state, action in
                state.counter = state.counter + action.increment
                XCTAssertEqual(action, testAction)
                expectation.fulfill()
            }
        )
        // When
        reducer.reduce(&state, testAction)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1379))
    }

    func testCreateReducerOnActionCreator() {
        // Given
        var state = TestState(counter: 1337)
        let incrementActionCreator = createActionCreator(id: "Increment", payloadType: Int.self)
        let incrementAction = incrementActionCreator.createAction(payload: 42)
        let expectation = XCTestExpectation(description: debugDescription)
        let reducer: Reducer<TestState> = createReducer(
            reduceOn(incrementActionCreator) { state, action in
                state.counter = state.counter + action.payload
                XCTAssertEqual(action, incrementAction)
                expectation.fulfill()
            }
        )
        // When
        reducer.reduce(&state, incrementAction)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1379))
    }

    private struct TestState: Equatable {
        var counter: Int
    }

    private struct TestAction: Action, Equatable {
        let increment: Int
    }
}
