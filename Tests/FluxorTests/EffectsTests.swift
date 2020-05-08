/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
@testable import Fluxor
import XCTest

// swiftlint:disable nesting

class EffectsTests: XCTestCase {
    var action = PassthroughSubject<Action, Never>()

    func testEffectsLookup() {
        // Given
        struct TestEffects: Effects {
            let notAnEffect = 42
            let anEffect = Effect.nonDispatching { $0.sink { print($0) } }
        }
        // When
        let testEffects = TestEffects()
        // Then
        XCTAssertEqual(testEffects.enabledEffects.count, 1)
    }

    func testEffectRunDispatching() throws {
        // Given
        let effect = Effect.dispatching { (actionPublisher: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> in
            actionPublisher.eraseToAnyPublisher()
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

    func testEffectCreatedFromCancellable() {
        // Given
        let effectCreator = { (actionPublisher: AnyPublisher<Action, Never>) -> AnyCancellable in
            actionPublisher.sink { print($0) }
        }
        // When
        let effect = Effect.nonDispatching(effectCreator)
        // Then
        guard case .nonDispatching = effect else { XCTFail("The effect type is wrong."); return }
    }
}
