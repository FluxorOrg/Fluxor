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
    private var store: Store<TestState>!
    private var reducer: ((TestState, Action) -> TestState)!

    override func setUp() {
        super.setUp()
        store = Store(initialState: TestState(type: .initial, lastAction: nil))
    }

    /// Does the `Reducer`s get called?
    func testDispatchUsesReducers() {
        // Given
        let action = TestAction()
        XCTAssertEqual(store.state.type, .initial)
        XCTAssertNil(store.state.lastAction)
        store.register(reducer: testReducer)
        store.register(reducer: createReducer { state, action in
            state.type = .modifiedAgain
            state.lastAction = String(describing: action)
        })
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(store.state.type, .modifiedAgain)
        XCTAssertEqual(store.state.lastAction, String(describing: action))
    }

    /// Does the `Effects` get triggered?
    func testEffects() {
        // Given
        let interceptor = TestInterceptor<TestState>()
        TestEffects.threadCheck = { XCTAssertEqual(Thread.current, Thread.main) }
        store.register(effects: TestEffects())
        store.register(interceptor: interceptor)
        let firstAction = TestAction()
        // When
        store.dispatch(action: firstAction)
        // Then
        wait(for: [TestEffects.expectation], timeout: 1)
        let dispatchedActions = interceptor.dispatchedActionsAndStates.map(\.action)
        XCTAssertEqual(dispatchedActions.count, 3)
        XCTAssertEqual(dispatchedActions[0] as! TestAction, firstAction)
        XCTAssertEqual(dispatchedActions[1] as! AnonymousActionWithoutPayload, TestEffects.responseAction)
        XCTAssertEqual(dispatchedActions[2] as! AnonymousActionWithEncodablePayload, TestEffects.generateAction)
        XCTAssertEqual(TestEffects.lastAction, TestEffects.generateAction)
    }

    /// Does the `Interceptor` receive the right `Action` and modified `State`?
    func testInterceptors() {
        // Given
        let action = TestAction()
        let interceptor = TestInterceptor<TestState>()
        store.register(reducer: testReducer)
        store.register(interceptor: interceptor)
        let oldState = store.state
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 0)
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(interceptor.dispatchedActionsAndStates.count, 1)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].action as! TestAction, action)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].oldState, oldState)
        XCTAssertEqual(interceptor.dispatchedActionsAndStates[0].newState, store.state)
    }

    /// Does a change in `State` publish new value for `Selector`?
    func testSelectMapPublisher() {
        // Given
        let selector = createRootSelector(keyPath: \TestState.type)
        let store = Store(initialState: TestState(type: .initial, lastAction: nil), reducers: [testReducer])
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = store.select(selector).sink {
            if $0 == .modified {
                expectation.fulfill()
            }
        }
        // When
        store.dispatch(action: TestAction())
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }

    /// Does a change in `State` publish new value for key path?
    func testSelectKeyPathPublisher() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil), reducers: [testReducer])
        let expectation = XCTestExpectation(description: debugDescription)
        let cancellable = store.select(\.type).sink {
            if $0 == .modified {
                expectation.fulfill()
            }
        }
        // When
        store.dispatch(action: TestAction())
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }

    /// Can we select the current value for `Selector`?
    func testSelectMap() {
        // Given
        let selector = createRootSelector(keyPath: \TestState.type)
        let store = Store(initialState: TestState(type: .initial, lastAction: nil), reducers: [testReducer])
        let valueBeforeAction = store.selectCurrent(selector)
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent(selector)
        XCTAssertEqual(valueAfterAction, .modified)
    }

    /// Can we select the current value for key path?
    func testSelectKeyPath() {
        // Given
        let store = Store(initialState: TestState(type: .initial, lastAction: nil), reducers: [testReducer])
        let valueBeforeAction = store.selectCurrent(\.type)
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent(\.type)
        XCTAssertEqual(valueAfterAction, .modified)
    }

    private struct TestAction: Action, Equatable {}

    private struct TestState: Encodable, Equatable {
        var type: TestType
        var lastAction: String?
    }

    private enum TestType: String, Encodable {
        case initial
        case modified
        case modifiedAgain
    }

    private let testReducer: Reducer<TestState> = createReducer { state, action in
        state.type = .modified
        state.lastAction = String(describing: action)
    }

    private class TestEffects: Effects {
        static let responseActionIdentifier = "TestResponseAction"
        static let responseActionCreator = createActionCreator(id: TestEffects.responseActionIdentifier)
        static let responseAction = TestEffects.responseActionCreator.createAction()
        static let generateActionCreator = createActionCreator(id: "TestGenerateAction", payloadType: Int.self)
        static let generateAction = TestEffects.generateActionCreator.createAction(payload: 42)
        static let expectation = XCTestExpectation()
        static var lastAction: AnonymousActionWithEncodablePayload<Int>?
        static var threadCheck: (() -> Void)!

        let testEffect = Effect.dispatching {
            $0.ofType(TestAction.self)
                .receive(on: DispatchQueue.global(qos: .background))
                .map { _ in TestEffects.responseAction }
                .eraseToAnyPublisher()
        }

        let anotherTestEffect = Effect.dispatching {
            $0.withIdentifier(TestEffects.responseActionIdentifier)
                .handleEvents(receiveOutput: { _ in TestEffects.threadCheck() })
                .map { _ in TestEffects.generateAction }
                .eraseToAnyPublisher()
        }

        let yetAnotherTestEffect = Effect.nonDispatching {
            $0.wasCreated(by: TestEffects.generateActionCreator)
                .sink(receiveValue: { action in
                    TestEffects.lastAction = action
                    TestEffects.expectation.fulfill()
                })
        }
    }
}

extension AnonymousActionWithoutPayload: Equatable {
    public static func == (lhs: AnonymousActionWithoutPayload, rhs: AnonymousActionWithoutPayload) -> Bool {
        lhs.id == rhs.id
    }
}

extension AnonymousActionWithEncodablePayload: Equatable where Payload == Int {
    public static func == (lhs: AnonymousActionWithEncodablePayload<Payload>,
                           rhs: AnonymousActionWithEncodablePayload<Payload>) -> Bool {
        lhs.id == rhs.id && lhs.payload == rhs.payload
    }
}
