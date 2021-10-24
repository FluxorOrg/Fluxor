/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

#if canImport(Combine)
import Combine
#else
import OpenCombine
#endif

// MARK: - SwiftUI observation

public extension Store {
    /**
     Creates an `ObservableValue` from the given `Selector`.

     > **_NOTE:_** This method is deprecated. Use the `StoreValue` property wrapper instead.

     - Parameter selector: The `Selector`s to use for observing
     - Returns: An `ObservableValue` based on the given `Selector`
     */
    @available(*, deprecated, message: "observe will be removed in future version. Use the @StoreValue property wrapper instead.")
    func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return .init(store: self, selector: selector)
    }
}

/**
 An `ObservableValue` can be wrapped in an `ObservedObject` property wrapper.
 With the given `Selector` it selects a slice of the `State` for SwiftUI to automatically observe.

 > **_NOTE:_** This extension is deprecated. Use the `StoreValue` property wrapper instead.
 */
@available(*, deprecated, message: "ObservableValue will be removed in future version. Use the @StoreValue property wrapper instead.")
public class ObservableValue<Value>: ObservableObject {
    /// The current value. This will change everytime the `State` in the `Store` changes
    @Published public private(set) var current: Value
    private var cancellable: AnyCancellable!

    /**
     Initializes the `ObservableValue` with a `Selector` and the `Store` from where to select.

     - Parameter store: The `Store` to select from
     - Parameter selector: The `Selector` to use for selecting
     */
    public init<State, Environment>(store: Store<State, Environment>, selector: Selector<State, Value>) {
        self.current = store.selectCurrent(selector)
        self.cancellable = store.select(selector).assign(to: \.current, on: self)
    }
}
