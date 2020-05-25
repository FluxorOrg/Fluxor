<p align="center">
    <br />
    <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Fluxor-logo.png" width="400" max-width="90%" alt="Fluxor" />
</p>

# Testing Selectors, Reducers and Effects

Every part of an application using Fluxor is highly testable. The separation of the [`Action`](Sources/Fluxor/Action.swift) (instructions), [`Selectors`](Sources/Fluxor/Selector.swift) (reading), [`Reducer`](Sources/Fluxor/Reducer.swift) (mutating) and [`Effect`](Sources/Fluxor/Effects.swift) (asynchronous) make each part decoupled, testable and easier to grasp.

But to help out when testing components using Fluxor or asynchronous [`Effects`](Sources/Fluxor/Effects.swift), Fluxor comes with a separate package (**[FluxorTestSupport](Sources/FluxorTestSupport)**) with a [`MockStore`](Sources/FluxorTestSupport/MockStore.swift) and extensions on [`Effect`](Sources/Fluxor/Effects.swift) to make them run syncronously.

[FluxorTestSupport](Sources/FluxorTestSupport) should be linked in unit testing targets.

## Mocking out the `Store`

The [`MockStore`](Sources/FluxorTestSupport/MockStore.swift) can be used to mock the [`Store`](Sources/Fluxor/Store.swift) being used.

### Setting a specific `State`

With [`MockStore`](Sources/FluxorTestSupport/MockStore.swift) it is possible, from a test, to set a specific `State` to help test a specific scenario.

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

The [`MockStore`](Sources/FluxorTestSupport/MockStore.swift) can be used to override [`Selectors`](Sources/Fluxor/Selector.swift) so that they always return a specific value.

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

The [`TestInterceptor`](Sources/FluxorTestSupport/TestInterceptor.swift) can be registered on the [`Store`](Sources/Fluxor/Store.swift). When registered it gets all [`Actions`](Sources/Fluxor/Action.swift) dispatched and `State` changes. Everything it intercepts gets saved in an array in the order received. This can be used to assert which [`Actions`](Sources/Fluxor/Action.swift) are dispatched in a test.

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

The [`MockStore`](Sources/FluxorTestSupport/MockStore.swift) uses this internally behind the `stateChanges` property.

## Running an `Effect`

An [`Effect`](Sources/Fluxor/Effects.swift) is inherently asynchronous, so in order to test it in a synchronous test, without a lot of boilerplate code, FluxorTestSupport comes with a` run` function that executes the [`Effect`](Sources/Fluxor/Effects.swift) with a specific [`Action`](Sources/Fluxor/Action.swift). It is possible to run both `.dispatchingOne`,` .dispatchingMultiple` and `.nonDispatching`, but the result will be different.

When running `.dispatchingOne` and` .dispatchingMultiple`, it is possible to specify the expected number of dispatched [`Actions`](Sources/Fluxor/Action.swift) and the dispatched [`Actions`](Sources/Fluxor/Action.swift) will also be returned.

When running `.nonDispatching`, nothing is awaited and nothing is returned.

```swift
import FluxorTestSupport
import XCTest

class SettingsEffectsTests: XCTestCase {
    func testSetBackground() {
        let effects = SettingsEffects()
        let action = Actions.setBackgroundColor(payload: .red)
        let result: [Action] = try effects.setBackgroundColor.run(with: action)
        XCTAssertEqual(result[0], Actions.hideColorPicker())
    }
}
```
