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
    var store: Store<TestState>!
    var reducer: ((TestState, Action) -> TestState)!

    override func setUp() {
        super.setUp()
        store = Store(initialState: TestState(type: .initial, lastAction: nil))
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
        store.register(reducer: Reducer<TestState, Action>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        store.register(reducer: Reducer<TestState, Action>(reduce: { state, action in
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

    // Does the interceptor receive the right action and modified state?
    func testInterceptors() {
        // Given
        let action = TestAction()
        let interceptor = TestStoreInterceptor()
        store.register(interceptor: interceptor)
        store.register(reducer: Reducer<TestState, Action>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 0)
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 1)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].action as! TestAction, action)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].newState, store.state)
    }

    func testSelect() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        let expectation = XCTestExpectation(description: debugDescription)
        // When
        let cancellable = store.select { $0.type }.sink {
            XCTAssertEqual($0, store.state.type)
            expectation.fulfill()
        }
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }
}

struct TestAction: Action, Equatable {}
struct TestResponseAction: Action, Equatable {}
struct TestGenerateAction: Action, Equatable {}

struct TestState: Encodable, Equatable {
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

class TestStoreInterceptor: StoreInterceptor {
    typealias State = TestState
    var dispatchedActionsAndStates: [(action: Action, newState: TestState)] = []

    func actionDispatched(action: Action, newState: TestState) {
        dispatchedActionsAndStates.append((action, newState))
    }
}
