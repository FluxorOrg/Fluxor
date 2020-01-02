/**
* FluxorTests
*  Copyright (c) Morten Bjerg Gregersen 2020
*  MIT license, see LICENSE file for details
*/


import Combine
@testable import Fluxor
import XCTest

// swiftlint:disable force_cast

class StoreTests: XCTestCase {
    fileprivate var store: Store<TestState>!
    fileprivate var reducer: ((TestState, Action) -> TestState)!

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
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
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
            XCTAssertEqual(Thread.current, Thread.main)
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
        XCTAssertEqual(TestEffects.lastAction, TestEffects.generateAction)
        wait(for: [TestEffects.expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    // Does the interceptor receive the right action and modified state?
    func testInterceptors() {
        // Given
        let action = TestAction()
        let interceptor = TestStoreInterceptor<TestState>()
        store.register(interceptor: interceptor)
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
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

    // Does a change in state publish new substate for selector?
    func testSelectMapPublisher() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = store.select { $0.type }.sink {
            if $0 == .modified {
                expectation.fulfill()
            }
        }
        // When
        store.dispatch(action: TestAction())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    // Does a change in state publish new substate for key path?
    func testSelectKeyPathPublisher() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = store.select(\.type).sink {
            if $0 == .modified {
                expectation.fulfill()
            }
        }
        // When
        store.dispatch(action: TestAction())
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    // Can we select the current substate for selector?
    func testSelectMap() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        let valueBeforeAction = store.selectCurrent { $0.type }
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent { $0.type }
        XCTAssertEqual(valueAfterAction, .modified)
    }

    // Can we select the current substate for key path?
    func testSelectKeyPath() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: Reducer<TestState>(reduce: { state, action in
            var state = state
            state.type = .modified
            state.lastAction = String(describing: action)
            return state
        }))
        let valueBeforeAction = store.selectCurrent(\.type)
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent(\.type)
        XCTAssertEqual(valueAfterAction, .modified)
    }
}

private struct TestAction: Action, Equatable {}
private struct TestResponseAction: Action, Equatable {}
private struct TestGenerateAction: Action, Equatable {}

private struct TestState: Encodable, Equatable {
    var type: TestType
    var lastAction: String?

    enum TestType: String, Encodable {
        case initial
        case modified
        case modifiedAgain
    }
}

private class TestEffects: Effects {
    lazy var effects: [Effect] = [testEffect, anotherTestEffect, yetAnotherTestEffect]
    let actions: ActionPublisher

    static let responseAction = TestResponseAction()
    static let generateAction = TestGenerateAction()
    static let expectation = XCTestExpectation()
    static var lastAction: TestGenerateAction?

    required init(_ actions: ActionPublisher) {
        self.actions = actions
    }

    lazy var testEffect: Effect = {
        .dispatching(actions
            .ofType(TestAction.self)
            .flatMap { _ in Just(Self.responseAction) }
            .eraseToAnyPublisher())
    }()

    lazy var anotherTestEffect: Effect = {
        .dispatching(actions
            .ofType(TestResponseAction.self)
            .flatMap { _ in Just(Self.generateAction) }
            .eraseToAnyPublisher())
    }()

    lazy var yetAnotherTestEffect: Effect = {
        .nonDispatching(actions
            .ofType(TestGenerateAction.self)
            .sink(receiveValue: { action in
                TestEffects.lastAction = action
                TestEffects.expectation.fulfill()
        }))
    }()
}
