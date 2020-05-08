/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
@testable import Fluxor
import XCTest

// swiftlint:disable nesting force_cast

class EffectsTests: XCTestCase {
    var action = PassthroughSubject<Action, Never>()

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

    func testEffectRunDispatchingOne() throws {
        // Given
        let action2 = Test2Action()
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 1
        let effect = Effect.dispatchingOne {
            $0.ofType(Test1Action.self)
                .map { _ in
                    expectation.fulfill()
                    return action2
                }
                .eraseToAnyPublisher()
        }
        // When
        let action = Test1Action()
        let actions: [Action] = try effect.run(with: action)
        effect.run(with: action) // Returns early because of wrong type
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(actions[0] as! Test2Action, action2)
        XCTAssertThrowsError(try effect.run(with: action, expectedCount: 2))
    }

    func testEffectRunDispatchingMultiple() throws {
        // Given
        let action2 = Test2Action()
        let action3 = Test3Action()
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 1
        let effect = Effect.dispatchingMultiple {
            $0.ofType(Test1Action.self)
                .map { _ in
                    expectation.fulfill()
                    return [action2, action3]
                }
                .eraseToAnyPublisher()
        }
        // When
        let action = Test1Action()
        let actions: [Action] = try effect.run(with: action, expectedCount: 2)
        effect.run(with: action) // Returns early because of wrong type
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(actions[0] as! Test2Action, action2)
        XCTAssertEqual(actions[1] as! Test3Action, action3)
    }

    func testEffectRunNonDispatching() throws {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        expectation.expectedFulfillmentCount = 1
        let effect = Effect.nonDispatching {
            $0.sink { _ in expectation.fulfill() }
        }
        // When
        let action = Test1Action()
        effect.run(with: action)
        XCTAssertThrowsError(try effect.run(with: action, expectedCount: 1)) // Returns early because of wrong type
        // Then
        wait(for: [expectation], timeout: 1)
    }
}

private struct Test1Action: Action {}

private struct Test2Action: Action, Equatable {
    let id = UUID()
}

private struct Test3Action: Action, Equatable {
    let id = UUID()
}
