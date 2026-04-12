Fluxor integrates with SwiftUI through the `FluxorSwiftUI` package.

The modern integration is based on `@State`, `@Environment`, `@Bindable`, and focused property wrappers instead of `ObservableObject`, `@StateObject`, or `@EnvironmentObject`.

## Injecting the `Store`

Own the `Store` at the root of the view tree with `@State` and inject it through the environment.

```swift
import Fluxor
import FluxorSwiftUI
import SwiftUI

struct RootView: View {
    @State private var store = Store(
        initialState: AppState(),
        reducers: [
            Reducer(
                ReduceOn(SetName.self) { state, action in
                    state.name = action.name
                }
            )
        ]
    )

    var body: some View {
        FeatureView()
            .environment(store)
    }
}
```

Child views read the store with `@Environment`.

```swift
struct FeatureView: View {
    @Environment(Store<AppState, Void>.self) private var store

    var body: some View {
        Button("Reset") {
            store.send(SetName(name: ""))
        }
    }
}
```

## Selecting values

`@FluxorSelect` reads a value from the store and only updates when the selected value changes.

```swift
struct GreetingView: View {
    @FluxorSelect<AppState, Void, String>(Selectors.name) private var name: String

    var body: some View {
        Text(name)
    }
}
```

## Creating bindings

Use `@FluxorBinding` when a SwiftUI control should both read from the store and dispatch an action when edited.

```swift
struct EditGreetingView: View {
    @FluxorBinding<AppState, Void, String>(Selectors.name, send: { SetName(name: $0) })
    private var name: String

    var body: some View {
        TextField("Name", text: $name)
    }
}
```

`store.binding(get:send:)` is still available as a small interop helper when a `Binding` is needed directly.

## Focused projections and `@Bindable`

For more advanced forms, use `@FluxorProjection` to create a focused observable projection from the environment store, then bind through `@Bindable`.

```swift
struct ProfileForm: View {
    @FluxorProjection<AppState, Void, String>(Selectors.name, send: { SetName(name: $0) })
    private var nameProjection: StoreProjection<AppState, Void, String>

    var body: some View {
        @Bindable var nameProjection = nameProjection

        return TextField("Name", text: $nameProjection.value)
    }
}
```

This keeps the view focused on the feature state it edits instead of binding against the entire store.
