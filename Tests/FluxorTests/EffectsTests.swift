/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
@testable import Fluxor
import FluxorTestSupport
import XCTest

// swiftlint:disable nesting force_cast

class EffectsTests: XCTestCase {
    var action = PassthroughSubject<Action, Never>()

    /// Can we lookup `Effect`s?
    func testEffectsLookup() {
        // Given
        struct TestEffects: Effects {
            let notAnEffect = 42
            let anEffect = Effect.nonDispatching { $0.sink { _ in } }
        }
        // When
        let testEffects = TestEffects()
        // Then
        XCTAssertEqual(testEffects.enabledEffects.count, 1)
    }

    /// Can we run a single dispatching `Effect`?
    func testEffectRunDispatchingOne() throws {
        // Given
        let action1 = Test1Action()
        let action2 = Test2Action()
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 1
        let effect = Effect.dispatchingOne {
            $0.ofType(Test1Action.self)
                .map {
                    XCTAssertEqual($0, action1)
                    expectation.fulfill()
                    return action2
                }
                .eraseToAnyPublisher()
        }
        // When
        let actions = try EffectRunner.run(effect, with: action1)!
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(actions.count, 1)
        XCTAssertEqual(actions[0] as! Test2Action, action2)
        XCTAssertThrowsError(try EffectRunner.run(effect, with: action1, expectedCount: 2))
    }

    /// Can we run a multi dispatching `Effect`?
    func testEffectRunDispatchingMultiple() throws {
        // Given
        let action1 = Test1Action()
        let action2 = Test2Action()
        let action3 = Test3Action()
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 1
        let effect = Effect.dispatchingMultiple {
            $0.ofType(Test1Action.self)
                .map {
                    XCTAssertEqual($0, action1)
                    expectation.fulfill()
                    return [action2, action3]
                }
                .eraseToAnyPublisher()
        }
        // When
        let actions = try EffectRunner.run(effect, with: action1, expectedCount: 2)!
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(actions.count, 2)
        XCTAssertEqual(actions[0] as! Test2Action, action2)
        XCTAssertEqual(actions[1] as! Test3Action, action3)
        XCTAssertThrowsError(try EffectRunner.run(effect, with: action1, expectedCount: 3))
    }

    /// Can we run a non dispatching `Effect`?
    func testEffectRunNonDispatching() throws {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 2
        let action = Test1Action()
        let effect = Effect.nonDispatching {
            $0.sink {
                XCTAssertEqual($0 as! Test1Action, action)
                expectation.fulfill()
            }
        }
        // When
        XCTAssertNil(try EffectRunner.run(effect, with: action))
        XCTAssertNil(try EffectRunner.run(effect, with: action, expectedCount: 9))
        // Then
        wait(for: [expectation], timeout: 1)
    }

    /// Only here for test coverage of ActionRecorder's empty completion function.
    func testActionRecorderCompletion() throws {
        var cancellable: AnyCancellable!
        let effect = Effect.dispatchingOne {
            let publisher = PassthroughSubject<Action, Never>()
            cancellable = $0.sink {
                publisher.send($0)
                publisher.send(completion: .finished)
            }
            return publisher.eraseToAnyPublisher()
        }
        try EffectRunner.run(effect, with: Test1Action(), expectedCount: 1)
        XCTAssertNotNil(cancellable)
    }
}

private struct Test1Action: Action, Equatable {
    let id = UUID()
}

private struct Test2Action: Action, Equatable {
    let id = UUID()
}

private struct Test3Action: Action, Equatable {
    let id = UUID()
}
