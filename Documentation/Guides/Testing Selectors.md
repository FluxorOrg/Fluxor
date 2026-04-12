# Testing `Selector`s

`Selector`s are state projectors. They can be tested by mapping a known state value directly.

```swift
import Fluxor
import XCTest

private enum Selectors {
    static let name = Selector<AppState, NameState>(\.name)
}

final class SelectorsTests: XCTestCase {
    func testNameSelector() {
        let state = AppState(name: NameState(firstName: "Tim", lastName: "Cook"))

        XCTAssertEqual(Selectors.name.map(state), state.name)
    }
}
```

Memoized selectors created with `Selector.combine(...)` should be tested through observable behavior, not by reproducing the caching logic. A good test asserts that a projection closure is only re evaluated when one of its selected inputs changes.
