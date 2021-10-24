Fluxor is based on Combine and is therefore ideal to use with SwiftUI. When SwiftUI can be imported, some extra types and extension for `Store` will be available.

## Observing a value in the `Store`

When you want to observe a value in the `Store`, the `StoreValue` property wrapper can be used. To use it, first you need to make the `Store` available for the property wrapper by adding it to the `StorePropertyWrapper` helper. This only needs to be done once, so it is recommended that you do it the same place as you instantiate your `Store`. When this is set up just wrap the property in the `@StoreValue` property wrapper by specifying the `Selector` used to select the value. 

> **_NOTE:_** Be aware, that the app will crash if there is no `Store` instance added matching the `State` of the `Selector`. 

```swift
import Fluxor
import SwiftUI

struct DrawView: View {
    @StoreValue(Selectors.canClear) private var canClear: Bool
    
    var body: some View {
        Button(action: { ... }, label: { Text("Clear") })
            .disabled(!canClear)
    }
}
```

## Binding to a value in the `Store`

The `Store` is extended with functions to create [`Bindings`](https://developer.apple.com/documentation/swiftui/binding) to a value in the `State` and use an `ActionTemplate` to update the value through the `Store`. The [`Binding`](https://developer.apple.com/documentation/swiftui/binding) can be used like any other bindings in SwiftUI. When the value in the [`Binding`](https://developer.apple.com/documentation/swiftui/binding) is changed an `Action` will be dispatched on the `Store` based on the specified `ActionTemplate`.

```swift
import Fluxor
import SwiftUI

struct GreetingView: View {
    @EnvironmentObject var store: Store<AppState, AppEnvironment>
    
    var body: some View {
        TextField("Greeting", text: store.binding(get: Selectors.getGreeting, send: Actions.setGreeting))
    }
}
```

## Binding to a value which can be enabled and disabled

When the [`Binding`](https://developer.apple.com/documentation/swiftui/binding) has a `Bool` value, it can be created with a `ActionTemplate` for enabling the value (making it `true`) and another one for disabling the value (making it `false`).

```swift
import Fluxor
import SwiftUI

struct DrawView: View {
    @EnvironmentObject var store: Store<AppState, AppEnvironment>

    var body: some View {
        Button(action: { store.dispatch(action: Actions.askToClear()) }, label: { Text("Clear") })
            .actionSheet(isPresented: store.binding(get: Selectors.isClearOptionsVisible,
                                                    enable: Actions.askToClear,
                                                    disable: Actions.cancelClear)) {
                clearActionSheet
            }
    }

    private var clearActionSheet: ActionSheet {
        .init(
            title: Text("Clear"),
            message: Text("Are you sure you want to clear?"),
            buttons: [
                .destructive(Text("Yes, clear")) {
                    store.dispatch(action: Actions.clear())
                },
                .cancel(Text("Cancel")) {
                    store.dispatch(action: Actions.cancelClear())
                }
            ]
        )
    }
}
```
