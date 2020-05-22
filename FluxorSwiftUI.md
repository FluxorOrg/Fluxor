<p align="center">
    <br />
    <img src="https://raw.githubusercontent.com/FluxorOrg/Fluxor/master/Assets/Fluxor-logo.png" width="400" max-width="90%" alt="Fluxor" />
</p>

# Using Fluxor with SwiftUI

Fluxor is based on Combine and is therefore ideal to use with SwiftUI. It comes with a separate package (**[FluxorSwiftUI](Sources/FluxorSwiftUI)**) with extensions for [`Store`](Sources/Fluxor/Store.swift) and types that can be used directly in [SwiftUI Views](https://developer.apple.com/documentation/swiftui/view).

## Observing a value

The [`ObservableValue`](Sources/FluxorSwiftUI/ObservableValue.swift) can be used to observe a value in the `State`. It can be created by calling the `observe` function found in the [`Store`](Sources/Fluxor/Store.swift) extension. When wrapping the [`ObservableValue`](Sources/FluxorSwiftUI/ObservableValue.swift) in an [`@ObservedObject`](https://developer.apple.com/documentation/swiftui/observedobject) property wrapper, its `current` property can be used like any other value wrapped in a [`@State`](https://developer.apple.com/documentation/swiftui/state) property wrapper.

```swift
import FluxorSwiftUI
import SwiftUI

struct DrawView: View {
    @ObservedObject var canClear = Current.store.observe(Selectors.canClear)
    
    var body: some View {
        Button(action: { ... }, label: { Text("Clear") })
            .disabled(!canClear.current)
    }
}
```

## Binding a value which can be changed

The [`ValueBinding`](Sources/FluxorSwiftUI/ValueBinding.swift) can be used to create a [`Binding`](https://developer.apple.com/documentation/swiftui/binding) to a value in the `State` and use an [`ActionTemplate`](Sources/Fluxor/Action.swift) to update the value through the [`Store`](Sources/Fluxor/Store.swift). The `binding` property on [`ValueBinding`](Sources/FluxorSwiftUI/ValueBinding.swift) will create a [`Binding`](https://developer.apple.com/documentation/swiftui/binding) which can be used like any other bindings. The value can also manually be updated using the [`update`](Sources/FluxorSwiftUI/ValueBinding.swift) function. This will dispatch an `Action` on the `Store` based on the specified [`ActionTemplate`](Sources/Fluxor/Action.swift).

```swift
import FluxorSwiftUI
import SwiftUI

struct GreetingView: View {
    var greeting = Current.store.binding(get: Selectors.getGreeting, send: Actions.setGreeting)
    
    var body: some View {
        TextField("Greeting", text: greeting.binding)
    }
}
```

## Binding a value which can be enabled and disabled

When the [`ValueBinding`](Sources/FluxorSwiftUI/ValueBinding.swift) has a `Bool` value, it can be created with a [`ActionTemplate`](Sources/Fluxor/Action.swift) for enabling the value (making it `true`) and another one for disabling the value (making it `false`). When the value is `Bool` and the payload for the [`ActionTemplate`](Sources/Fluxor/Action.swift) is either `Void` or `Bool`, the [`ValueBinding`](Sources/FluxorSwiftUI/ValueBinding.swift) gains more functions beside the `update` function to `toggle`, `enable` and `disable` the value.

```swift
import FluxorSwiftUI
import SwiftUI

struct DrawView: View {
    var showClearActionSheet = Current.store.binding(get: Selectors.isClearOptionsVisible,
                                                     enable: Actions.askToClear,
                                                     disable: Actions.cancelClear)

    var body: some View {
        Button(action: { self.showClearActionSheet.enable() }, label: { Text("Clear") })
            .actionSheet(isPresented: showClearActionSheet.binding) { clearActionSheet }
    }

    private var clearActionSheet: ActionSheet {
        .init(title: Text("Clear"),
              message: Text("Are you sure you want to clear?"),
              buttons: [
                  .destructive(Text("Yes, clear")) {
                      Current.store.dispatch(action: Actions.clear())
                  },
                  .cancel(Text("Cancel")) {
                      self.showClearActionSheet.disable()
                  }
              ])
    }
}
```