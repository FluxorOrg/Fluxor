<p align="center">
    <br />
    <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Fluxor-logo.png" width="400" max-width="90%" alt="Fluxor" />
</p>

<p align="center">
    <b>Unidirectional Data Flow in Swift - inspired by <a href="https://redux.js.org">Redux</a> and <a href="https://ngrx.io">NgRx</a>.</b><br />
    Based on <a href="https://developer.apple.com/documentation/combine">Combine</a> - ideal for use with <a href="https://developer.apple.com/documentation/swiftui">SwiftUI</a>.<br />
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

* `Store` contains an immutable state (the **Single Source of Truth**).
* `Action`s are dispatched on the **Store** to update the state.
* `Reducer`s gives the **Store** a new state based on the **Actions** dispatched.
* `Selector`s selects (and eventually transform) part(s) of the state to use (eg. in views).
* `Effect`s gets triggered by **Actions**, and can perform async task which in turn can dispatch new **Actions**.
* `Interceptor`s intercepts every dispatched **Action** and state change for easier debugging.

![](https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Diagram.png)

## Installation

Fluxor can be installed as a dependency to your project using [Swift Package Manager](https://swift.org/package-manager), by simply adding `https://github.com/FluxorOrg/Fluxor.git`.

### Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Xcode 11.0+
- Swift 5.2+

## Usage
As a minimum, an app using Fluxor will need a `Store`, an `Action`, a `Reducer`, a `Selector` and a state.

Here is a setup where firing the `IncrementAction` (1) will increment the `counter` (2) in `AppState` (3), and when selecting with the `counterSelector` (4) on the `Store` will publish the `counter` everytime the state changes (5).

```swift
import Combine
import Fluxor
import Foundation

// 3
struct AppState {
    var counter: Int
}

// 1
struct IncrementAction: Action {
    let increment: Int
}

// 4
let counterSelector = Selector(keyPath: \AppState.counter)

let store = Store(initialState: AppState(counter: 0))
store.register(reducer: Reducer(
    ReduceOn(IncrementAction.self) { state, action in
        state.counter += action.increment // 2
    }
))

let cancellable = store.select(counterSelector).sink {
    print("Current count: \($0)") // 5
}

store.dispatch(action: IncrementAction(increment: 42))
// Will print out "Current count: 42"
```

### Side Effects
The above example is a simple use case, where an `Action` is dispatched and the state is updated by a `Reducer`. In cases where something should happen when an `Action` is dispatched (eg. fetching data from the internet or some system service), Fluxor provides `Effects`.

`Effects` are registered in the `Store` and will receive all `Action`s dispatched. An `Effect` will in most cases be a `Publisher` mapped from the dispatched `Action` - the mapped `Action` will be dispatched on the `Store`.

Alternatively an `Effect` can also be a `Cancellable` when it don't need to have an `Action` dispatched.

```swift
import Combine
import Fluxor
import Foundation

class TodosEffects: Effects {
    typealias Environment = AppEnvironment

    let fetchTodos = Effect<Environment>.dispatchingOne { actions, environment in
        actions.ofType(FetchTodosAction.self)
            .flatMap { _ in
                environment.todoService.fetchTodos()
                    .map { DidFetchTodosAction(todos: $0) }
                    .catch { _ in Just(DidFailFetchingTodosAction(error: "An error occurred.")) }
            }
            .eraseToAnyPublisher()
    }
}
```

### Intercepting actions and changes
If read-only access to all `Action`s dispatched and state changes is needed, an `Interceptor` can be used. `Interceptor` is just a protocol, and when registered in the `Store`, instances of types conforming to this protocol will receive a callback everytime an `Action` is dispatched.

Fluxor comes with two implementations of `Interceptor`:

* `PrintInterceptor` for printing `Action`s and state changes to the log.
* `TestInterceptor` to help assert that specific `Action`s was dispatched in unit tests.

## Packages for using it with SwiftUI and testing
Fluxor comes with packages, to make it easier to use it with SwiftUI and for testing apps using Fluxor.

* [More info on how to use it with SwiftUI](https://fluxor.dev/Using%20Fluxor%20with%20SwiftUI.html)
* [More info on how to test apps using Fluxor](https://fluxor.dev/Test%20Support.html)

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
