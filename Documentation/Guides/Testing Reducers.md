# Testing `Reducer`s

In Fluxor `Reducer`s are basically pure functions which takes an instance of `State` and an `Action`, and returns a new `State`.
This means that given the same parameters, the `Reducer` will always return the same output.

```swift
let appReducer = Reducer<CounterState>(
    ReduceOn(IncrementAction.self) { state, action in
        state.counter += action.value
    }
)

class ReducersTests: XCTestCase {
    func testIncrementAction() {
        // Given
        var state = CounterState(counter: 0)
        // When
        appReducer.reduce(&state, IncrementAction(value: 1))
        // Then
        XCTAssertEqual(state.counter, 1)
    }
}

struct CounterState {
    var counter: Int
}

struct IncrementAction: Action {
    let value: Int
}
```