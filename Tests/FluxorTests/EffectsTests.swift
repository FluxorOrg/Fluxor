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

    func testEffectCreators() {
        // Given
        class TestEffects: Effects {
            let notAnEffect = 42
            let anEffect = Effect.nonDispatching { $0.sink { print($0) } }
        }
        // When
        let testEffects = TestEffects()
        // Then
        XCTAssertEqual(testEffects.effects.count, 1)
    }

    func testCreateEffectCreatorFromPublisher() {
        // Given
        let effectCreator = { (actionPublisher: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> in
            actionPublisher.filter { _ in true }.eraseToAnyPublisher()
        }
        // When
        let effect = Effect.dispatching(effectCreator)
        // Then
        guard case .dispatching = effect else { XCTFail("The effect type is wrong."); return }
    }

    func testCreateEffectCreatorFromCancellable() {
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
