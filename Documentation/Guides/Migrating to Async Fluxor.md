# Migrating to Async Fluxor

This release is a breaking modernization of Fluxor. The fundamental idea is unchanged: a single store owns the state, actions describe changes, reducers mutate state synchronously, selectors read derived values, and effects react asynchronously.

## What changed

* `Action` is now a typed `Sendable` marker protocol.
* `Store` is `@MainActor` and uses async streams instead of Combine publishers.
* `Effect` is async first and typed on the action it handles.
* The old Combine action operators were removed.
* SwiftUI integration moved into `FluxorSwiftUI`.
* Test helpers moved into `FluxorTestSupport`.
* Macros live in `FluxorMacros`.

## Core API changes

### Dispatching actions

Before:

```swift
store.dispatch(action: IncrementAction(increment: 1))
```

Now:

```swift
store.send(IncrementAction(increment: 1))
```

### Selecting state

Before:

```swift
let cancellable = store.select(Selectors.counter).sink { value in
    print(value)
}
```

Now:

```swift
Task {
    for await value in store.select(Selectors.counter) {
        print(value)
    }
}
```

For synchronous reads, use `current(_:)`.

```swift
let counter = store.current(Selectors.counter)
```

### Effects

Before:

```swift
let fetch = Effect<Environment>.dispatchingOne { actions, environment in
    actions.ofType(FetchTodos.self)
        .flatMap { _ in environment.todoService.fetchTodos() }
        .map(DidFetchTodos.init)
        .eraseToAnyPublisher()
}
```

Now:

```swift
let fetch = Effect<AppState, AppEnvironment>.on(FetchTodos.self) { _, context in
    let todos = try await context.environment.todoService.fetchTodos()
    context.send(DidFetchTodos(todos: todos))
}
```

## SwiftUI changes

Before:

```swift
@EnvironmentObject var store: Store<AppState, AppEnvironment>
```

Now:

```swift
@Environment(Store<AppState, AppEnvironment>.self) private var store
```

Use the new wrappers for view focused access:

* `@FluxorSelect`
* `@FluxorBinding`
* `@FluxorProjection`

## Testing changes

* Use `EffectRunner.run(...)` for async effect assertions.
* Use `TestInterceptor` to assert action sequences.
* Use `MockStore` when selector overrides are needed in tests.
