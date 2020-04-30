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

    /// Can the state be reduced with `ReduceOn`s with one `ActionTemplate`?
    func testCreateReducerOneTemplateInReduceOn() {
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

    /// Can the state be reduced with `ReduceOn`s with multiple `ActionTemplate`s?
    func testCreateReducerMulitpleTemplateInReduceOn() {
        // Given
        var state = TestState(counter: 1337)
        let incrementActionTemplate = ActionTemplate(id: "Increment", payloadType: Int.self)
        let decrementActionTemplate = ActionTemplate(id: "Decrement", payloadType: Int.self)
        let otherDecrementActionTemplate = ActionTemplate(id: "Other Decrement", payloadType: Int.self)
        let incrementExpectation = XCTestExpectation(description: debugDescription + "-incrementExpectation")
        incrementExpectation.expectedFulfillmentCount = 1
        let decrementExpectation = XCTestExpectation(description: debugDescription + "-decrementExpectation")
        decrementExpectation.expectedFulfillmentCount = 2
        let reducer = Reducer<TestState>(
            ReduceOn(incrementActionTemplate) { _, _ in
                incrementExpectation.fulfill()
            },
            ReduceOn(decrementActionTemplate, otherDecrementActionTemplate) { state, action in
                state.counter -= action.payload
                decrementExpectation.fulfill()
            }
        )
        // When
        reducer.reduce(&state, incrementActionTemplate(payload: 1))
        reducer.reduce(&state, decrementActionTemplate(payload: 1))
        reducer.reduce(&state, otherDecrementActionTemplate(payload: 2))
        // Then
        wait(for: [incrementExpectation, decrementExpectation], timeout: 1)
        XCTAssertEqual(state, TestState(counter: 1334))
    }

    private struct TestState: Equatable {
        var counter: Int
    }

    private struct IncrementAction: Action, Equatable {
        let increment: Int
    }
}
