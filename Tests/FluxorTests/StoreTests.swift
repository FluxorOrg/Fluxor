/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
@testable import Fluxor
import FluxorTestSupport
import XCTest

// swiftlint:disable force_cast

class StoreTests: XCTestCase {
    private var environment: TestEnvironment!
    private var store: Store<TestState, TestEnvironment>!
    private var reducer: ((TestState, Action) -> TestState)!

    override func setUp() {
        super.setUp()
        environment = TestEnvironment()
        store = Store(initialState: TestState(type: .initial, lastAction: nil), environment: environment)
    }

    /// Does the `Reducer`s get called?
    func testDispatchUsesReducers() {
        // Given
        let action = TestAction()
        XCTAssertEqual(store.state.type, .initial)
        XCTAssertNil(store.state.lastAction)
        store.register(reducer: testReducer)
        store.register(reducer: Reducer<TestState> { state, action in
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
        let envCheckExpectation = XCTestExpectation(description: debugDescription)
        envCheckExpectation.expectedFulfillmentCount = 3
        let interceptor = TestInterceptor<TestState>()
        TestEffects.threadCheck = { XCTAssertEqual(Thread.current, Thread.main) }
        TestEffects.envCheck = { XCTAssertEqual($0, self.environment); envCheckExpectation.fulfill() }
        store.register(effects: TestEffects())
        store.register(interceptor: interceptor)
        let firstAction = TestAction()
        // When
        store.dispatch(action: firstAction)
        // Then
        wait(for: [TestEffects.expectation, envCheckExpectation], timeout: 1)
        let dispatchedActions = interceptor.stateChanges.map(\.action)
        XCTAssertEqual(dispatchedActions.count, 4)
        XCTAssertEqual(dispatchedActions[0] as! TestAction, firstAction)
        XCTAssertEqual(dispatchedActions[1] as! AnonymousAction<Void>, TestEffects.responseAction)
        XCTAssertEqual(dispatchedActions[2] as! AnonymousAction<Int>, TestEffects.generateAction)
        XCTAssertEqual(dispatchedActions[3] as! AnonymousAction<Void>, TestEffects.unrelatedAction)
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
        XCTAssertEqual(interceptor.stateChanges.count, 0)
        // When
        store.dispatch(action: action)
        // Then
        XCTAssertEqual(interceptor.stateChanges.count, 1)
        XCTAssertEqual(interceptor.stateChanges[0].action as! TestAction, action)
        XCTAssertEqual(interceptor.stateChanges[0].oldState, oldState)
        XCTAssertEqual(interceptor.stateChanges[0].newState, store.state)
    }

    /// Does a change in `State` publish new value for `Selector`?
    func testSelectMapPublisher() {
        // Given
        let selector = Selector(keyPath: \TestState.type)
        let store = Store(initialState: TestState(type: .initial, lastAction: nil),
                          environment: TestEnvironment(),
                          reducers: [testReducer])
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

    /// Can we select the current value for `Selector`?
    func testSelectMap() {
        // Given
        let selector = Selector(keyPath: \TestState.type)
        let store = Store(initialState: TestState(type: .initial, lastAction: nil),
                          environment: TestEnvironment(),
                          reducers: [testReducer])
        let valueBeforeAction = store.selectCurrent(selector)
        XCTAssertEqual(valueBeforeAction, .initial)
        // When
        store.dispatch(action: TestAction())
        // Then
        let valueAfterAction = store.selectCurrent(selector)
        XCTAssertEqual(valueAfterAction, .modified)
    }

    /// Does the convenience initializer give an `Void` environment?
    func testEmptyEnvironment() {
        // Given
        VoidTestEffects.envCheck = { XCTAssertEqual(String(describing: $0), "()") }
        let store = Store(initialState: TestState(type: .initial, lastAction: nil))
        store.register(effects: VoidTestEffects())
        // When
        store.dispatch(action: TestAction())
        // Then
        wait(for: [VoidTestEffects.expectation], timeout: 1)
    }

    private struct TestAction: Action, Equatable {}

    private struct TestState: Encodable, Equatable {
        var type: TestType
        var lastAction: String?
    }

    private struct TestEnvironment: Equatable {
        let id = UUID()
    }

    private enum TestType: String, Encodable {
        case initial
        case modified
        case modifiedAgain
    }

    private let testReducer = Reducer<TestState> { state, action in
        state.type = .modified
        state.lastAction = String(describing: action)
    }

    private struct TestEffects: Effects {
        typealias Environment = TestEnvironment
        static let responseActionIdentifier = "TestResponseAction"
        static let responseActionTemplate = ActionTemplate(id: TestEffects.responseActionIdentifier)
        static let responseAction = TestEffects.responseActionTemplate.createAction()
        static let generateActionTemplate = ActionTemplate(id: "TestGenerateAction", payloadType: Int.self)
        static let generateAction = TestEffects.generateActionTemplate.createAction(payload: 42)
        static let unrelatedActionTemplate = ActionTemplate(id: "UnrelatedAction")
        static let unrelatedAction = TestEffects.unrelatedActionTemplate.createAction()
        static let expectation = XCTestExpectation()
        static var lastAction: AnonymousAction<Int>?
        static var threadCheck: (() -> Void)!
        static var envCheck: ((Environment) -> Void)!

        let testEffect = Effect<Environment>.dispatchingOne { actions, environment in
            actions.ofType(TestAction.self)
                .handleEvents(receiveOutput: { _ in TestEffects.envCheck(environment) })
                .receive(on: DispatchQueue.global(qos: .background))
                .map { _ in TestEffects.responseAction }
                .eraseToAnyPublisher()
        }

        let anotherTestEffect = Effect<Environment>.dispatchingMultiple { actions, environment in
            actions.withIdentifier(TestEffects.responseActionIdentifier)
                .handleEvents(receiveOutput: { _ in TestEffects.threadCheck() })
                .handleEvents(receiveOutput: { _ in TestEffects.envCheck(environment) })
                .map { _ in [TestEffects.generateAction, TestEffects.unrelatedAction] }
                .eraseToAnyPublisher()
        }

        let yetAnotherTestEffect = Effect<Environment>.nonDispatching { actions, environment in
            actions.wasCreated(from: TestEffects.generateActionTemplate)
                .handleEvents(receiveOutput: { _ in TestEffects.envCheck(environment) })
                .sink(receiveValue: { action in
                    TestEffects.lastAction = action
                    TestEffects.expectation.fulfill()
                })
        }
    }

    private struct VoidTestEffects: Effects {
        typealias Environment = Void
        static let expectation = XCTestExpectation()
        static var envCheck: ((Environment) -> Void)!

        let testEffect = Effect<Environment>.nonDispatching { actions, env in
            actions.sink { _ in
                VoidTestEffects.envCheck(env)
                VoidTestEffects.expectation.fulfill()
            }
        }
    }
}

extension AnonymousAction: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
