<p align="center">
    <img src="https://github.com/MortenGregersen/Fluxor/blob/master/Assets/Fluxor-logo.png" width="400" max-width="90%" alt="Fluxor" />
</p>

<p align="center">
    <b>Unidirectional Data Flow in Swift - inspired by Redux and NgRx.</b><br>
    Based on Combine - ideal for use with SwiftUI.
</p>

![Platforms](https://img.shields.io/badge/platforms-Mac+iOS-brightgreen.svg?style=flat)
![Swift version](https://img.shields.io/badge/Swift-5.1-brightgreen.svg)
![Swift PM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg?style=flat)
![Twitter](https://img.shields.io/badge/twitter-@mortengregersen-blue.svg?style=flat)

![Test](https://github.com/MortenGregersen/Fluxor/workflows/CI/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/f8f269fac2ca81c09856/maintainability)](https://codeclimate.com/github/MortenGregersen/Fluxor/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f8f269fac2ca81c09856/test_coverage)](https://codeclimate.com/github/MortenGregersen/Fluxor/test_coverage)

## Why do I need Fluxor?
When developing apps, it can quickly become difficult to keep track of the flow of data. Data flows in multiple directions and can easily become inconsistent with *Multiple Sources of Truth*.

With Fluxor, data flows in only one direction, there is only one *Single Source of Truth*, updates to the state are done with pure functions, the flow in the app can easily be followed, and all the individual parts can be unit tested separately.

## How does it work?
Fluxor is made up from the following types:

* [**Store**](Sources/Fluxor/Store.swift) contains an immutable state (the **Single Source of Truth**).
* [**Actions**](Sources/Fluxor/Action.swift) are dispatched on the **Store** to update the state.
* [**Reducers**](Sources/Fluxor/Reducer.swift) gives the **Store** a new state based on the **Actions** dispatched.
* [**Selectors**](Sources/Fluxor/Selector.swift) selects (and eventually transform) part(s) of the state to use (eg. in views).
* [**Effects**](Sources/Fluxor/Effects.swift) gets triggered by **Actions**, and can perform async task which in turn can dispatch new **Actions**.
* [**Interceptors**](Sources/Fluxor/Interceptor.swift) intercepts every dispatched **Action** and state change for easier debugging.

![](https://github.com/MortenGregersen/Fluxor/blob/master/Assets/Diagram.png)

## Installation

Fluxor can be installed as a dependency to your project using [Swift Package Manager](https://swift.org/package-manager), by simply adding `https://github.com/MortenGregersen/Fluxor.git`.

### Requirements

- iOS 13.0+ / Mac OS X 10.15+ / tvOS 13.0+
- Xcode 11.0+
- Swift 5.1+

## Usage
As a minimum, an app using Fluxor will need a `Store`, an `Action`, a `Reducer`, a `Selector` and a state.

Here is a setup where firing the `IncrementAction` (1) will increment the `counter` (2) in `AppState` (3), and when selecting with the `counterSelector` (4) on the `Store` will publish the `counter` everytime the state changes (5).

```swift
import Combine
import Fluxor
import Foundation

// 3
struct AppState: Encodable {
    var counter: Int
}

// 1
struct IncrementAction: Action {
    let increment: Int
}

// 4
let counterSelector = createRootSelector(keyPath: \AppState.counter)

let store = Store(initialState: AppState(counter: 0))
store.register(reducer: createReducer(
    reduceOn(IncrementAction.self) { state, action in
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

`Effects` are registered in the `Store` and will receive all `Actions` dispatched. An `Effect` will in most cases be a `Publisher` mapped from the dispatched `Actions` - the mapped `Action` will be dispatched on the `Store`.

Alternatively an `Effect` can also be a `Cancellable` when it don't need to have an `Action` dispatched.

```swift
import Combine
import Fluxor
import Foundation

class TodosEffects: Effects {
    lazy var effects: [Effect] = [fetchTodos]
    private let actions: ActionPublisher

    required init(_ actions: ActionPublisher) {
        self.actions = actions
    }

    lazy var fetchTodos = createEffect(
        actions
            .ofType(FetchTodosAction.self)
            .flatMap { _ in
                Current.todoService.fetchTodos()
                    .map { DidFetchTodosAction(todos: $0) }
                    .catch { _ in Just(DidFailFetchingTodosAction(error: "An error occurred.")) }
            }
            .eraseToAnyPublisher()
    )
}
```

### Intercepting actions and changes
If read-only access to all `Actions` dispatched and state changes is needed, an `Interceptor` can be used. `Interceptor` is just a protocol, and when registered in the `Store`, instances of types conforming to this protocol will receive a callback everytime an `Action` is dispatched.

Fluxor comes with two implementations of `Interceptor`:

* [**PrintInterceptor**](Sources/Fluxor/Interceptors/PrintInterceptor.swift) for printing `Action`s and state changes to the log.
* [**TestInterceptor**](Sources/Fluxor/Interceptors/TestInterceptor.swift) to help assert that specific `Action`s was dispatched in unit tests.

## Debugging with FluxorExplorer
Fluxor has a companion app, [**FluxorExplorer**](https://github.com/MortenGregersen/FluxorExplorer), which helps when debugging apps using Fluxor. FluxorExplorer lets you look through the dispatched `Action`s and state changes, to debug the data flow of the app.

![](https://github.com/MortenGregersen/Fluxor/blob/master/Assets/FluxorExplorer.png)

To learn more about how to use FluxorExplorer, [go to the repository for the app](https://github.com/MortenGregersen/FluxorExplorer).

### Setting up
The only thing need, for FluxorExplorer to receive all actions and state changes from an app, is to register the [FluxorExplorerStoreInterceptor](https://github.com/MortenGregersen/FluxorExplorerStoreInterceptor) in the app's `Store`. When FluxorExplorer and the app are running on the same network (eg. running the app on the iOS Simulator), they will automatically connect and send/receive data.

```swift
let store = Store(initialState: AppState())
#if DEBUG
store.register(interceptor: FluxorExplorerStoreInterceptor(displayName: UIDevice.current.name))
#endif
```

It is recommended to only register the interceptor in `DEBUG` builds.

## Apps using Fluxor

### Real world apps

* [FluxorExplorer](https://github.com/MortenGregersen/FluxorExplorer)

### Sample apps

* [FluxorSampleToDo](https://github.com/MortenGregersen/FluxorSampleToDo)
