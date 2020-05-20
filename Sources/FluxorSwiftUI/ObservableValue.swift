/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor

public extension Store {
    func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return .init(store: self, selector: selector)
    }
}

public class ObservableValue<T>: ObservableObject {
    public private(set) var current: T { willSet { objectWillChange.send() } }
    private var cancellable: AnyCancellable!

    public init<State: Encodable>(store: Store<State>, selector: Selector<State, T>) {
        self.current = store.selectCurrent(selector)
        self.cancellable = store.select(selector).assign(to: \.current, on: self)
    }
}
