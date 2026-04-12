<p align="center">
    <br />
    <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Fluxor-logo-light.png#gh-light-mode-only" width="400" max-width="90%" alt="Fluxor" />
    <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Fluxor-logo-dark.png#gh-dark-mode-only" id="dark-logo" width="400" max-width="90%" alt="Fluxor" />
</p>

<p align="center">
    <b>Unidirectional Data Flow in Swift - inspired by <a href="https://redux.js.org">Redux</a> and <a href="https://ngrx.io">NgRx</a>.</b><br />
    Async first state management for Swift and SwiftUI.<br />
    <br />
    <a href="https://swiftpackageindex.com/FluxorOrg/Fluxor">
        <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFluxorOrg%2FFluxor%2Fbadge%3Ftype%3Dswift-versions" alt="Swift version" />
    </a>
    <a href="https://swiftpackageindex.com/FluxorOrg/Fluxor">
        <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFluxorOrg%2FFluxor%2Fbadge%3Ftype%3Dplatforms" alt="Platforms" />
    </a>
    <br />
    <img src="https://github.com/FluxorOrg/Fluxor/workflows/CI/badge.svg" alt="CI" />
    <a href="https://fluxor.dev">
        <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/gh-pages/badge.svg" alt="Documentation" />
    </a>
    <a href="https://codeclimate.com/github/FluxorOrg/Fluxor/maintainability">
        <img src="https://api.codeclimate.com/v1/badges/f2ea66abc81e4a578a31/maintainability" alt="Maintainability" />
    </a>
    <a href="https://codeclimate.com/github/FluxorOrg/Fluxor/test_coverage">
        <img src="https://api.codeclimate.com/v1/badges/f2ea66abc81e4a578a31/test_coverage" alt="Test Coverage" />
    </a>
    <a href="https://twitter.com/mortengregersen">
        <img src="https://img.shields.io/badge/twitter-@mortengregersen-blue.svg?style=flat" alt="Twitter" />
    </a>
</p>

## Why do I need Fluxor?
When developing apps, it can quickly become difficult to keep track of the flow of data. Data flows in multiple directions and can easily become inconsistent with *Multiple Sources of Truth*.

With Fluxor, data flows in only one direction, there is only one *Single Source of Truth*, updates to the state are done with pure functions, the flow in the app can easily be followed, and all the individual parts can be unit tested separately.

## How does it work?
Fluxor is made up from the following types:

* `Store` contains the state (the **Single Source of Truth**).
* `Action`s are dispatched on the **Store** to update the state.
* `Reducer`s synchronously mutate the state based on dispatched **Action** values.
* `Selector`s selects (and eventually transform) part(s) of the state to use (eg. in views).
* `Effect`s react to **Action** values, perform async work, and can dispatch follow up **Action** values.
* `Interceptor`s intercept every dispatched **Action** and state change for easier debugging.

![](https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Diagram.png)

## Installation

Fluxor can be installed as a dependency to your project using [Swift Package Manager](https://swift.org/package-manager), by simply adding `https://github.com/FluxorOrg/Fluxor.git`.

The package exposes four products:

* `Fluxor` for the core store, reducers, selectors, effects, and interceptors.
* `FluxorSwiftUI` for `SwiftUI` integration.
* `FluxorMacros` for action, selector, and effects macros.
* `FluxorTestSupport` for testing helpers.

### Requirements

* `Fluxor`: Swift 6.2+, Apple platforms and Linux.
* `FluxorSwiftUI`: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, macCatalyst 17+.

## Usage
As a minimum, an app using Fluxor will need a `Store`, an `Action`, a `Reducer`, a `Selector` and a state.

Here is a setup where firing `IncrementAction` updates `AppState`, and selecting with `counterSelector` gives both synchronous access through `current(_:)` and async observation through `select(_:)`.

```swift
import Fluxor

struct AppState: Sendable {
    var counter = 0
}

struct IncrementAction: Action {
    let increment: Int
}

enum Selectors {
    static let counter = Selector(\AppState.counter)
}

let store = Store(initialState: AppState(counter: 0))

store.register(reducer: Reducer(
    ReduceOn(IncrementAction.self) { state, action in
        state.counter += action.increment
    }
))

store.send(IncrementAction(increment: 42))
print(store.current(Selectors.counter))

Task {
    for await count in store.select(Selectors.counter) {
        print("Current count: \(count)")
    }
}
```

### Side Effects
When an action should trigger async work, register an `Effect`. Effects are typed, async, and cancellable. Each effect gets an `EffectContext` with access to the current state, the environment, and `send(_:)`.

```swift
import Fluxor

struct TodosEffects: Effects {
    typealias State = TodosState
    typealias Environment = AppEnvironment

    let fetchTodos = Effect<State, Environment>.on(FetchTodosAction.self) { _, context in
        do {
            let todos = try await context.environment.todoService.fetchTodos()
            context.send(DidFetchTodosAction(todos: todos))
        } catch {
            context.send(DidFailFetchingTodosAction(error: "An error occurred."))
        }
    }
}

store.register(effects: TodosEffects())
```

### SwiftUI
Use `FluxorSwiftUI` when integrating with SwiftUI and Observation. Root views should own the store with `@State`, inject it into the environment, and read it from child views with `@Environment`.

```swift
import Fluxor
import FluxorSwiftUI
import SwiftUI

struct RootView: View {
    @State private var store = Store(
        initialState: AppState(),
        reducers: [
            Reducer(
                ReduceOn(IncrementAction.self) { state, action in
                    state.counter += action.increment
                }
            )
        ]
    )

    var body: some View {
        CounterView()
            .environment(store)
    }
}

struct CounterView: View {
    @Environment(Store<AppState, Void>.self) private var store
    @FluxorSelect<AppState, Void, Int>(Selectors.counter) private var counter: Int

    var body: some View {
        VStack {
            Text("\\(counter)")
            Button("Increment") {
                store.send(IncrementAction(increment: 1))
            }
        }
    }
}
```

For writable projections, use `@FluxorBinding` or `store.scope(...)` when a feature needs a focused observable projection that works with `@Bindable`.

`@FluxorProjection` is available when the projection itself should be sourced from the environment store and then bound through `@Bindable`.

### Macros
`FluxorMacros` adds authoring helpers while keeping the generated code explicit:

* `@FluxorAction("Load Todos")`
* `@FluxorSelector`
* `@FluxorEffects`

## Migration
If you are upgrading from the old Combine based API, start with [Migrating to Async Fluxor](Documentation/Guides/Migrating%20to%20Async%20Fluxor.md).

### Intercepting actions and changes
If read-only access to all `Action`s dispatched and state changes is needed, an `Interceptor` can be used. `Interceptor` is just a protocol, and when registered in the `Store`, instances of types conforming to this protocol will receive a callback everytime an `Action` is dispatched.

Fluxor comes with two implementations of `Interceptor`:

* `PrintInterceptor` for printing `Action`s and state changes to the log.
* `TestInterceptor` in `FluxorTestSupport` to help assert which actions were dispatched in tests.

## Packages for using it with SwiftUI and testing
Fluxor comes with packages, to make it easier to use it with SwiftUI and for testing apps using Fluxor.

* `FluxorSwiftUI`
* `FluxorTestSupport`

## Debugging with FluxorExplorer
Fluxor has a companion app, [**FluxorExplorer**](https://github.com/FluxorOrg/FluxorExplorer), which helps when debugging apps using Fluxor. FluxorExplorer lets you look through the dispatched `Action`s and state changes, to debug the data flow of the app.

FluxorExplorer is available on the App Store but also available as open source.

<a href="https://apps.apple.com/us/app/fluxorexplorer/id1515805273?mt=8">
	<img src="https://linkmaker.itunes.apple.com/en-us/badge-lrg.svg?releaseDate=2020-06-08&kind=iossoftware&bubble=ios_apps" style="width: 135px; height: 40px" alt="Download on the App Store" />
</a>

To learn more about how to use FluxorExplorer, [go to the repository for the app](https://github.com/FluxorOrg/FluxorExplorer).

![](https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/FluxorExplorer.png)


## Apps using Fluxor

### Real world apps

* [FluxorExplorer](https://github.com/FluxorOrg/FluxorExplorer)

### Sample apps

* [FluxorSampleToDo](https://github.com/FluxorOrg/FluxorSampleToDo)
