/*
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import OpenCombineShim

public extension Store {
    /**
     Creates an `ObservableValue` from the given `Selector`.

     - Parameter selector: The `Selector`s to use for observing
     - Returns: An `ObservableValue` based on the given `Selector`
     */
    func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return .init(store: self, selector: selector)
    }
}

/**
 An `ObservableValue` can be wrapped in an `ObservedObject`property wrapper.
 With the given `Selector` it selects a slice of the `State` for SwiftUI to automatically observe.
 */
public class ObservableValue<Value>: ObservableObject {
    /// The current value. This will change everytime the `State` in the `Store` changes
    @Published public private(set) var current: Value
    private var cancellable: AnyCancellable!

    /**
     Initializes the `ObservableValue` with a `Selector` and the `Store` from where to select.

     - Parameter store: The `Store` to select from
     - Parameter selector: The `Selector`s to use for selecting
     */
    public init<State, Environment>(store: Store<State, Environment>, selector: Selector<State, Value>) {
        self.current = store.selectCurrent(selector)
        self.cancellable = store.select(selector).assign(to: \.current, on: self)
    }
}
