# Fluxor

![Platforms](https://img.shields.io/badge/platforms-Mac+iOS-brightgreen.svg?style=flat)
![Swift version](https://img.shields.io/badge/Swift-5.1-brightgreen.svg)
![Swift PM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg?style=flat)
![Twitter](https://img.shields.io/badge/twitter-@mortengregersen-blue.svg?style=flat)

![Test](https://github.com/MortenGregersen/Fluxor/workflows/CI/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/f8f269fac2ca81c09856/maintainability)](https://codeclimate.com/github/MortenGregersen/Fluxor/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f8f269fac2ca81c09856/test_coverage)](https://codeclimate.com/github/MortenGregersen/Fluxor/test_coverage)

Unidirectional Data Flow in Swift - using Combine and ideal for use with SwiftUI. Fluxor is a Redux-like implementation, inspired by NgRx.

## Why do I need Fluxor?

## How does it work?
Fluxor is made up from the following types:

* [**Store**](Sources/Fluxor/Store.swift) contains an immutable state (the **Single Source of Truth**)
* [**Actions**](Sources/Fluxor/Action.swift) are dispatched on the **Store** to update the state
* [**Reducers**](Sources/Fluxor/Reducer.swift) gives the **Store** a new state based on the **Actions** dispatched
* [**Selectors**](Sources/Fluxor/Selector.swift) selects (and eventually transform) part(s) of the state to use (eg. in views)
* [**Effects**](Sources/Fluxor/Effects.swift) gets triggered by **Actions**, and can perform async task which in turn can dispatch new **Actions**
* [**Interceptors**](Sources/Fluxor/StoreInterceptor.swift) intercepts every dispatched **Action** and state change for easier logging and debugging

![](assets/Diagram.png)

## Installation

Fluxor can be installed as a dependency to your project using [Swift Package Manager](https://swift.org/package-manager), simply by adding `https://github.com/MortenGregersen/Fluxor.git`.

## Usage
```swift
import Combine
import Fluxor
import Foundation

struct AppState: Encodable {
    var counter: Int
}

struct IncrementAction: Action {
    let increment: Int
}

let counterReducer = createReducer { (state: AppState, action) in
    var state = state
    switch action {
    case let incrementAction as IncrementAction:
        state.counter += incrementAction.increment
    default: break
    }
    return state
}

let counterSelector = createRootSelector(keyPath: \AppState.counter)

let store = Store(initialState: AppState(counter: 0))
store.register(reducer: counterReducer)

let cancellable = store.select(counterSelector).sink {
    print("Current count: \($0)")
}

store.dispatch(action: IncrementAction(increment: 42))
```

### Side Effects
The above example is the simplest use case, where an `Action` is dispatched and the state is updated by a `Reducer`. In cases where something should happen when an `Action` is dispatched (eg. fetching data from the internet or some system service), Fluxor uses `Effects`.

`Effects` are registered in the `Store` and will receive all `Actions` dispatched. An `Effect` will in most cases a be a `Publisher` mapped from the disptched `Actions` - the mapped `Action` will be dispatched on the `Store`.

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
If you need read-only access to all `Actions` dispatched and state changes, `StoreInterceptor` can be used. `StoreInterceptor` is just a protocol, and instances of types conforming to this protocol will receive a callback everytime an `Action` is dispatched.

Fluxor comes with a `StoreInterceptor` for printing changes to the log (see [**PrintStoreInterceptor**](Sources/Fluxor/PrintStoreInterceptor.swift)).

## Debugging with FluxorExplorer

## Sample apps
