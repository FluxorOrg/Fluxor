//
//  StoreTests.swift
//  FluxorTests
//
//  Created by Morten Bjerg Gregersen on 18/09/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine
@testable import Fluxor
import XCTest

// swiftlint:disable force_cast

class StoreTests: XCTestCase {
    var store: Store<State>!
    var reducer: ((State, Action) -> State)!

    override func setUp() {
        super.setUp()
        store = Store(initialState: State(type: .initial, lastAction: nil))
    }

    // Does dispatching set the new action?
    func testDispatchSetsAction() {
        // Given
        let action = TestAction()
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = store.$action.sink { receivedAction in
            guard !(receivedAction is InitialAction) else { return }
            XCTAssertEqual(receivedAction as! TestAction, action)
            expectation.fulfill()
        }
        // When
        store.dispatch(action: action)
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    // Does dispatching use the registered reducers?
    func testDispatchUsesReducers() {
        // Given
        let action = TestAction()
        XCTAssertEqual(store.state.type, .initial)
        XCTAssertNil(store.state.lastAction)
        store.register(reducer: Reducer<State, Action>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        store.register(reducer: Reducer<State, Action>(reduce: { state, action in
            var state = state
            state.type = .modifiedAgain
            state.lastAction = String(describing: action)
            return state
        }))
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(store.state.type, .modifiedAgain)
        XCTAssertEqual(store.state.lastAction, String(describing: action))
    }

    // Does the effects get registered?
    func testEffects() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 4
        var dispatchedActions: [Action] = []
        let cancellable = store.$action.sink { receivedAction in
            dispatchedActions.append(receivedAction)
            expectation.fulfill()
        }
        store.register(effects: TestEffects.self)
        let firstAction = TestAction()
        // When
        store.dispatch(action: firstAction)
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(dispatchedActions.count, 4)
        XCTAssertTrue(dispatchedActions[0] is InitialAction)
        XCTAssertEqual(dispatchedActions[1] as! TestAction, firstAction)
        XCTAssertEqual(dispatchedActions[2] as! TestResponseAction, TestEffects.responseAction)
        XCTAssertEqual(dispatchedActions[3] as! TestGenerateAction, TestEffects.generateAction)
        XCTAssertNotNil(cancellable)
    }
}

struct TestAction: Action, Equatable {}
struct TestResponseAction: Action, Equatable {}
struct TestGenerateAction: Action, Equatable {}

struct State: Encodable {
    var type: TestType
    var lastAction: String?

    enum TestType: String, Encodable {
        case initial
        case modified
        case modifiedAgain
    }
}

class TestEffects: Effects {
    lazy var effects: [Effect] = [testEffect, anotherTestEffect]
    let actions: ActionPublisher

    static let responseAction = TestResponseAction()
    static let generateAction = TestGenerateAction()

    required init(_ actions: ActionPublisher) {
        self.actions = actions
    }

    lazy var testEffect: Effect = {
        actions
            .ofType(TestAction.self)
            .flatMap { _ in Just(Self.responseAction) }
            .eraseToAnyPublisher()
    }()

    lazy var anotherTestEffect: Effect = {
        actions
            .ofType(TestResponseAction.self)
            .flatMap { _ in Just(Self.generateAction) }
            .eraseToAnyPublisher()
    }()
}
