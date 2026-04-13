Fluxor ships with a separate package, `FluxorTestSupport`, for testing views, reducers, selectors, and async effects.

`FluxorTestSupport` should only be linked in test targets.

The package currently provides:

* `MockStore` for stateful tests that need a real `Store` surface.
* `TestInterceptor` for capturing dispatched actions and state transitions.
* `EffectRunner` for running async effects with a controlled initial state.

## `MockStore`

`MockStore` wraps a real `Store`, keeps track of dispatched actions, and can override selectors for targeted scenarios.

```swift
import Fluxor
import FluxorTestSupport
import XCTest

@MainActor
final class GreetingViewTests: XCTestCase {
    func testGreetingUsesSelectorOverride() async {
        let store = MockStore(initialState: AppState())
        store.overrideSelector(Selectors.name, value: "Hi Bob")

        XCTAssertEqual(store.current(Selectors.name), "Hi Bob")
    }
}
```

## `TestInterceptor`

`TestInterceptor` captures state changes in dispatch order. This is useful when a reducer and one or more effects should emit a specific sequence of actions.

```swift
@MainActor
final class StoreTests: XCTestCase {
    func testLoadFlow() async throws {
        let interceptor = TestInterceptor<AppState>()
        let store = Store(initialState: AppState())
        store.register(interceptor: interceptor)

        store.send(LoadTodos())

        try await interceptor.waitForActions(expectedNumberOfActions: 1)
        XCTAssertTrue(interceptor.stateChanges[0].action is LoadTodos)
    }
}
```

## `EffectRunner`

`EffectRunner` runs an `Effect` by wiring it into a temporary store and returning the follow up actions it dispatches.

```swift
import Fluxor
import FluxorTestSupport
import XCTest

@MainActor
final class TodosEffectsTests: XCTestCase {
    func testFetchTodosDispatchesLoadedAction() async throws {
        let effect = Effect<AppState, Void>.on(FetchTodos.self) { _, context in
            context.send(DidFetchTodos(count: 3))
        }

        let actions = try await EffectRunner.run(
            effect,
            with: FetchTodos(),
            initialState: AppState()
        )

        XCTAssertEqual((actions.first as? DidFetchTodos)?.count, 3)
    }
}
```
