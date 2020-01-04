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

    /// Does dispatching set the new `Action`?
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

    /// Does dispatching use the registered `Reducer`s?
    func testDispatchUsesReducers() {
        // Given
        let action = TestAction()
        XCTAssertEqual(store.state.type, .initial)
        XCTAssertNil(store.state.lastAction)
        store.register(reducer: TestReducer())
        store.register(reducer: createReducer(reduce: { state, action in
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

    /// Does the `Effects` get registered?
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
        XCTAssertEqual(dispatchedActions[2] as! AnonymousAction, TestEffects.responseAction)
        XCTAssertEqual(dispatchedActions[3] as! AnonymousActionWithPayload, TestEffects.generateAction)
        XCTAssertEqual(TestEffects.lastAction, TestEffects.generateAction)
        wait(for: [TestEffects.expectation], timeout: 5)
        XCTAssertNotNil(cancellable)
    }

    /// Does the `StoreInterceptor` receive the right `Action` and modified `State`?
    func testInterceptors() {
        // Given
        let action = TestAction()
        let interceptor = TestStoreInterceptor<TestState>()
        store.register(interceptor: interceptor)
        store.register(reducer: TestReducer())
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 0)
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 1)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].action as! TestAction, action)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].newState, store.state)
    }

    /// Does a change in `State` publish new value for selector?
    func testSelectMapPublisher() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: TestReducer())
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

    /// Does a change in `State` publish new value for key path?
    func testSelectKeyPathPublisher() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: TestReducer())
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

    /// Can we select the current value for selector?
    func testSelectMap() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: TestReducer())
        let valueBeforeAction = store.selectCurrent { $0.type }
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent { $0.type }
        XCTAssertEqual(valueAfterAction, .modified)
    }

    /// Can we select the current value for key path?
    func testSelectKeyPath() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(reducer: TestReducer())
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

extension AnonymousAction: Equatable {
    public static func == (lhs: AnonymousAction, rhs: AnonymousAction) -> Bool {
        lhs.id == rhs.id
    }
}

extension AnonymousActionWithPayload: Equatable where Payload == Int {
    public static func == (lhs: AnonymousActionWithPayload<Payload>, rhs: AnonymousActionWithPayload<Payload>) -> Bool {
        lhs.id == rhs.id && lhs.payload == rhs.payload
    }
}

private struct TestState: Encodable, Equatable {
    var type: TestType
    var lastAction: String?

    enum TestType: String, Encodable {
        case initial
        case modified
        case modifiedAgain
    }
}

private struct TestReducer: Reducer {
    typealias State = TestState

    func reduce(state: TestState, action: Action) -> State {
        var state = state
        state.type = .modified
        state.lastAction = String(describing: action)
        return state
    }
}

private class TestEffects: Effects {
    lazy var effects: [Effect] = [testEffect, anotherTestEffect, yetAnotherTestEffect]
    let actions: ActionPublisher

    static let responseActionIdentifier = "TestResponseAction"
    static let responseAction = createAction(id: TestEffects.responseActionIdentifier)
    static let generateActionIdentifier = "TestGenerateAction"
    static let generateAction = createAction(id: TestEffects.generateActionIdentifier, payload: 42)
    static let expectation = XCTestExpectation()
    static var lastAction: AnonymousActionWithPayload<Int>?

    required init(_ actions: ActionPublisher) {
        self.actions = actions
    }

    lazy var testEffect = createEffect(
        actions
            .ofType(TestAction.self)
            .flatMap { _ in Just(Self.responseAction) }
            .eraseToAnyPublisher()
    )

    lazy var anotherTestEffect = createEffect(
        actions
            .withIdentifier(TestEffects.responseActionIdentifier)
            .flatMap { _ in Just(Self.generateAction) }
            .eraseToAnyPublisher()
    )

    lazy var yetAnotherTestEffect = createEffect(
        actions
            .withIdentifier(TestEffects.generateActionIdentifier)
            .sink(receiveValue: { action in
                TestEffects.lastAction = (action as! AnonymousActionWithPayload<Int>)
                TestEffects.expectation.fulfill()
            })
    )
}
