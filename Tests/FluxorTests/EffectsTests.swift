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
    @Published var action: Action = InitialAction()

    func testEffectCreators() {
        // Given
        class TestEffects: Effects {
            let notAnEffect = 42
            let anEffect = createEffectCreator { $0.sink { print($0) } }
        }
        // When
        let testEffects = TestEffects()
        // Then
        XCTAssertEqual(testEffects.effectCreators.count, 1)
    }

    func testCreateEffectCreatorFromPublisher() {
        // Given
        let createPublisher = { (actionPublisher: ActionPublisher) -> AnyPublisher<Action, Never> in
            actionPublisher.filter { _ in true }.eraseToAnyPublisher()
        }
        // When
        let effectCreator = createEffectCreator(createPublisher)
        let effect = effectCreator.createEffect(actionPublisher: $action)
        // Then
        guard case .dispatching = effect else { XCTFail("The effect type is wrong."); return }
        XCTAssertTrue(effectCreator is DispathingEffectCreator)
    }

    func testCreateEffectCreatorFromCancellable() {
        // Given
        let createPublisher = { (actionPublisher: ActionPublisher) -> AnyCancellable in
            actionPublisher.sink { print($0) }
        }
        // When
        let effectCreator = createEffectCreator(createPublisher)
        let effect = effectCreator.createEffect(actionPublisher: $action)
        // Then
        guard case .nonDispatching = effect else { XCTFail("The effect type is wrong."); return }
        XCTAssertTrue(effectCreator is NonDispathingEffectCreator)
    }
}
