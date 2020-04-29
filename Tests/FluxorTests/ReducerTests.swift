//
//  File.swift
//
//
//  Created by Morten Bjerg Gregersen on 29/02/2020.
//

import Fluxor
import XCTest

class ReducerTests: XCTestCase {
    /// Can the state be reduced with closures?
    func testCreateReducerClosure() {
        // Given
        var state = TestState(counter: 1337)
        let incrementAction = IncrementAction(increment: 42)
        let decrementActionTemplate = ActionTemplate(id: "Decrement", payloadType: Int.self)
        let decrementAction = decrementActionTemplate.createAction(payload: 1)
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 2
        let reducer = Reducer<TestState> { state, action in
            if let action = action as? IncrementAction {
                state.counter += action.increment
                XCTAssertEqual(action, incrementAction)
                expectation.fulfill()
            } else if let action = action as? AnonymousAction<Int> {
                state.counter -= action.payload
                XCTAssertEqual(action, decrementAction)
                expectation.fulfill()
            }
        }
        // When
        reducer.reduce(&state, incrementAction)
        reducer.reduce(&state, decrementAction)
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1378))
    }

    /// Can the state be reduced with `ReduceOn`?
    func testCreateReducerReduceOn() {
        // Given
        var state = TestState(counter: 1337)
        let incrementAction = IncrementAction(increment: 42)
        let decrementActionTemplate = ActionTemplate(id: "Decrement", payloadType: Int.self)
        let decrementAction = decrementActionTemplate.createAction(payload: 1)
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 2
        let reducer = Reducer<TestState>(
            ReduceOn(IncrementAction.self) { state, action in
                state.counter += action.increment
                XCTAssertEqual(action, incrementAction)
                expectation.fulfill()
            },
            ReduceOn(decrementActionTemplate) { state, action in
                state.counter -= action.payload
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
