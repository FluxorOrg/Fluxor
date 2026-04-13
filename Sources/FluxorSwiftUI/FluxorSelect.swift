/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import SwiftUI

@MainActor
private final class SelectionBox<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable> {
    private var storeIdentifier: ObjectIdentifier?
    private var selectorIdentifier: UUID?
    private var task: Task<Void, Never>?

    var currentValue: Value?

    isolated deinit {
        task?.cancel()
    }

    func connect(
        store: Store<StoreState, StoreEnvironment>,
        selector: Fluxor.Selector<StoreState, Value>
    ) {
        let nextStoreIdentifier = ObjectIdentifier(store)
        guard storeIdentifier != nextStoreIdentifier || selectorIdentifier != selector.id else { return }

        storeIdentifier = nextStoreIdentifier
        selectorIdentifier = selector.id
        currentValue = store.current(selector)
        task?.cancel()
        task = Task { @MainActor [weak self] in
            var iterator = store.select(selector).makeAsyncIterator()
            while !Task.isCancelled, let nextValue = await iterator.next() {
                guard let self else { return }
                if self.currentValue != nextValue {
                    self.currentValue = nextValue
                }
            }
        }
    }
}

@propertyWrapper
public struct FluxorSelect<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable>: @MainActor DynamicProperty {
    @Environment(Store<StoreState, StoreEnvironment>.self) private var store: Store<StoreState, StoreEnvironment>
    @State private var box = SelectionBox<StoreState, StoreEnvironment, Value>()

    private let selector: Fluxor.Selector<StoreState, Value>

    public init(_ selector: Fluxor.Selector<StoreState, Value>) {
        self.selector = selector
    }

    @MainActor
    public var wrappedValue: Value {
        box.currentValue ?? store.current(selector)
    }

    @MainActor
    public mutating func update() {
        box.connect(store: store, selector: selector)
    }
}
