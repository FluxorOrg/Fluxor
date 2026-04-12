# Testing `Reducer`s

`Reducer`s synchronously mutate state in place. That makes them straightforward to test in isolation.

```swift
import Fluxor
import XCTest

private let appReducer = Reducer<CounterState>(
    ReduceOn(IncrementAction.self) { state, action in
        state.counter += action.value
    }
)

final class ReducersTests: XCTestCase {
    func testIncrementAction() {
        var state = CounterState(counter: 0)

        appReducer.reduce(&state, action: IncrementAction(value: 1))

        XCTAssertEqual(state.counter, 1)
    }
}

private struct CounterState {
    var counter: Int
}

private struct IncrementAction: Action {
    let value: Int
}
```

If the store composes multiple reducers, prefer testing the combined store behavior separately from the individual reducer mutations.
