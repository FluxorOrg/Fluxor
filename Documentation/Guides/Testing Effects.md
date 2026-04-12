# Testing `Effect`s

In modern Fluxor, `Effect`s are async handlers that react to typed actions. The simplest way to test them is with `EffectRunner` from `FluxorTestSupport`.

`EffectRunner` executes an effect against a temporary store and returns the actions the effect dispatched.

```swift
import Fluxor
import FluxorTestSupport
import XCTest

@MainActor
final class SettingsEffectsTests: XCTestCase {
    func testSetBackgroundDispatchesHidePicker() async throws {
        let effect = Effect<AppState, Void>.on(SetBackground.self) { _, context in
            context.send(HideColorPicker())
        }

        let actions = try await EffectRunner.run(
            effect,
            with: SetBackground(color: .red),
            initialState: AppState()
        )

        XCTAssertEqual(actions.count, 1)
        XCTAssertTrue(actions[0] is HideColorPicker)
    }
}
```

When asserting cancellation behavior, use a real `Store` and unregister the effect registration while the effect is sleeping or awaiting work.
