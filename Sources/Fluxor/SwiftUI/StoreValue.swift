/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Combine
import SwiftUI

/**
 A property wrapper for observing a value in the `Store`.
 
     import Fluxor
     import SwiftUI

     struct DrawView: View {
         @StoreValue(Selectors.canClear) private var canClear: Bool
         
         var body: some View {
             Button(action: { ... }, label: { Text("Clear") })
                 .disabled(!canClear)
         }
     }
 
 > **_NOTE:_** Be sure to add your `Store` to `StorePropertyWrapper` before using this property wrapper.
 > Check the "Using Fluxor with SwiftUI" abstract for more information about how to use it.
 */
@propertyWrapper public struct StoreValue<State, Value> {
    /// The current value in the `Store`
    public var wrappedValue: Value { observableValue.current }
    private let observableValue: InternalObservableValue<Value>

    /**
     Initializes the `StoreValue` property wrapper with a `Selector`.

     - Parameter selector: The `Selector` to use for selecting
     */
    public init(_ selector: Selector<State, Value>) {
        // swiftlint:disable:next force_try
        let store: AnyEnvironmentStore<State> = try! StorePropertyWrapper.getStore()
        observableValue = InternalObservableValue(current: store.selectCurrent(selector),
                                                  publisher: store.select(selector))
    }
}

// This should be renamed to ObservableValue when the old one is removed
internal class InternalObservableValue<Value>: ObservableObject {
    /// The current value. This will change everytime the `State` in the `Store` changes
    @Published internal private(set) var current: Value
    private var cancellable: AnyCancellable!

    internal init(current: Value, publisher: AnyPublisher<Value, Never>) {
        self.current = current
        cancellable = publisher.assign(to: \.current, on: self)
    }
}

#endif
