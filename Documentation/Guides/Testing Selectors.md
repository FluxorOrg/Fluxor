# Testing `Selector`s

In Fluxor `Selector`s are projectors of `State`.  `Selector`s can be created by a `KeyPath`, by a closure or based on up to 5 other `Selector`s.
When a `Selector` is based on other `Selector`s, the projector takes the `Value`s from the others as parameters.

## Testing basic `Selector`s

The `Selector`'s `map` function takes the `State` and returns a `Value`.

```swift
struct Selectors {
    static let getNameState = Selector(keyPath: \AppState.name)
}

class SelectorsTests: XCTestCase {
    func testGetNameState() {
        // Given
        let state = AppState(name: NameState(firstName: "Tim", lastName: "Cook"))
        // Then
        XCTAssertEqual(Selectors.getNameState.map(state), state.name)
    }
}
```

## Testing `Selector`s based on `Selector`s

If a `Selector` is based on the `Value`s from other `Selector`s, it will also have a `projector` property.
The `projector` can be used in tests, to easily test the `Selector` without creating the full `State` instance.

```swift
extension Selectors {
    static let congratulations = Selector.with(getFullName, getBirthday) { fullName, birthday in
        "Congratulations \(fullName)! Today is \(birthday.month) \(birthday.day) - your birthday!"
    }
}

class SelectorsTests: XCTestCase {
    func testCongratulations() {
        XCTAssertEqual(Selectors.congratulations.projector("Tim Cook", Birthday(month: "November", day: "1")),
                       "Congratulations Tim Cook! Today is November 1 - your birthday!")
    }
}
```
