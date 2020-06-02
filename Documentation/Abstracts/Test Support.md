# Test support

Every part of an application using Fluxor is highly testable. The separation of the `Action` (instructions), `Selector`s (reading), `Reducer` (mutating) and `Effect` (asynchronous) make each part decoupled, testable and easier to grasp.

But to help out when testing components using Fluxor or asynchronous `Effect`s, Fluxor comes with a separate package (**FluxorTestSupport**) with a `MockStore`, `TestInterceptor` and an `EffectRunner` to make `Effect`s run syncronously.

FluxorTestSupport should be linked in unit testing targets.

## Mocking out the `Store`

The `MockStore` can be used to mock the `Store` being used.

### Setting a specific `State`

With `MockStore` it is possible, from a test, to set a specific `State` to help test a specific scenario.

```swift
import FluxorTestSupport
import XCTest

class GreetingView: XCTestCase {
    func testGreeting() {
        let mockStore = MockStore(initialState: AppState())
        let view = GreetingView(store: mockStore)
        XCTAssert(...)
        mockStore.setState(AppState(greeting: "Hi Bob!"))
        XCTAssert(...)
    }
}
```

### Overriding `Selectors`

The `MockStore` can be used to override `Selector`s so that they always return a specific value.

```swift
import FluxorTestSupport
import XCTest

class GreetingView: XCTestCase {
    func testGreeting() {
        let greeting = "Hi Bob!"
        let mockStore = MockStore(initialState: AppState(greeting: "Hi Steve!"))
        mockStore.overrideSelector(Selectors.getGreeting, value: greeting)
        let view = GreetingView(store: mockStore)
        XCTAssertEqual(view.greeting, greeting)
    }
}
```

## Intercepting `State` changes

The `TestInterceptor` can be registered on the `Store`. When registered it gets all `Action`s dispatched and `State` changes. Everything it intercepts gets saved in an array in the order received. This can be used to assert which `Action`s are dispatched in a test.

```swift
import FluxorTestSupport
import XCTest

class GreetingView: XCTestCase {
    func testGreeting() {
        let testInterceptor = TestInterceptor<AppState>()
        let store = Store(initialState: AppState())
        store.register(interceptor: self.testInterceptor)
        let view = GreetingView(store: store)
        XCTAssertEqual(testInteceptor.stateChanges.count, 0)
        view.updateGreeting()
        XCTAssertEqual(testInteceptor.stateChanges.count, 1)
    }
}
```

The `MockStore` uses this internally behind the `stateChanges` property.

## Running an `Effect`

An `Effect` is inherently asynchronous, so in order to test it in a synchronous test, without a lot of boilerplate code, FluxorTestSupport comes with a `run` function that executes the `Effect` with a specific `Action`. It is possible to run both `.dispatchingOne`,` .dispatchingMultiple` and `.nonDispatching`, but the result will be different.

When running `.dispatchingOne` and` .dispatchingMultiple`, it is possible to specify the expected number of dispatched `Action`s and the dispatched `Action`s will also be returned.

When running `.nonDispatching`, nothing is awaited and nothing is returned.

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
