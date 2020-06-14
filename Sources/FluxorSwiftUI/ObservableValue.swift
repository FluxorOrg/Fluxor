/*
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor

public extension Store {
    /**
     Creates an `ObservableValue` from the given `Selector`.

     - Parameter selector: The `Selector`s to use for observing
     - Returns: An `ObservableValue` based on the given `Selector`
     */
    func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return .init(store: self, selector: selector)
    }

    /**
     Creates an `ObservableValue` from the given `Selector` and input.

     - Parameter selector: The `Selector`s to use for observing
     - Parameter input: The `Input` to the `Selector`
     - Returns: An `ObservableValue` based on the given `Selector`
     */
    func observe<Value, Input>(_ selector: SelectorWithInput<State, Value, Input>, input: Input) -> ObservableValue<Value> {
        return .init(store: self, selector: selector, input: input)
    }
}

/**
 An `ObservableValue` can be wrapped in an `ObservedObject`property wrapper.
 With the given `Selector` it selects a slice of the `State` for SwiftUI to automatically observe.
 */
public class ObservableValue<Value>: ObservableObject {
    /// The current value. This will change everytime the `State` in the `Store` changes
    public private(set) var current: Value { willSet { objectWillChange.send() } }
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

    /**
     Initializes the `ObservableValue` with a `Selector`, the `Store` from where to select, and input to the `Selector`.

     - Parameter store: The `Store` to select from
     - Parameter selector: The `Selector`s to use for selecting
     - Parameter input: The `Input` to the `Selector`
     */
    public init<State, Environment, Input>(store: Store<State, Environment>,
                                           selector: SelectorWithInput<State, Value, Input>,
                                           input: Input) {
        self.current = store.selectCurrent(selector, input: input)
        self.cancellable = store.select(selector, input: input).assign(to: \.current, on: self)
    }
}
