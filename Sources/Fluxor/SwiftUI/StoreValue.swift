/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Combine
import SwiftUI

@propertyWrapper
public struct StoreValue<State, Value> {
    public var wrappedValue: Value { observableValue.current }
    private let observableValue: InternalObservableValue<Value>

    public init(_ selector: Selector<State, Value>) {
        let store: AnyEnvironmentStore<State> = try! StorePropertyWrapper.getStore()
        observableValue = InternalObservableValue(current: store.selectCurrent(selector), publisher: store.select(selector))
    }
}

// TODO: This should be renamed to ObservableValue when the old one is removed
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
