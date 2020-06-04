# Testing `Effect`s

In Fluxor `Effect`s are `Publisher`s based on the actions dispatched in the `Store`. They are inherently asynchronous, so in order to test it in a synchronous test some boilerplate code is needed.

Fluxor comes with an `EffectRunner` (in the FluxorTestSupport package), which will run the `Effect` with a specified `Action` and waits for a given number of expected `Action`s published by the `Effect`.

```swift
import FluxorTestSupport
import XCTest

class SettingsEffectsTests: XCTestCase {
    func testSetBackground() {
        let effects = SettingsEffects()
        let action = Actions.setBackgroundColor(payload: .red)
        let result = try EffectRunner.run(effects.setBackgroundColor, with: action)!
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], Actions.hideColorPicker())
    }
}
```

To read more about the `EffectRunner`, take a look at the documentation for [FluxorTestSupport](https://fluxor.dev/Test%20Support.html).