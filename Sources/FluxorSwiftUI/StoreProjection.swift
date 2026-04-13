/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import Observation

@Observable
@MainActor
public final class StoreProjection<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable> {
    public var value: Value {
        didSet {
            guard !isApplyingStoreUpdate, oldValue != value else { return }
            store.send(erasing: action(value))
        }
    }

    private let store: Store<StoreState, StoreEnvironment>
    private let action: (Value) -> any Action
    private let selector: Fluxor.Selector<StoreState, Value>
    private var isApplyingStoreUpdate = false
    private var task: Task<Void, Never>?

    init(
        store: Store<StoreState, StoreEnvironment>,
        selector: Fluxor.Selector<StoreState, Value>,
        send action: @escaping (Value) -> any Action
    ) {
        self.store = store
        self.selector = selector
        self.action = action
        value = store.current(selector)
        task = Task { @MainActor [weak self] in
            var iterator = store.select(selector).makeAsyncIterator()
            while !Task.isCancelled, let nextValue = await iterator.next() {
                guard let self else { return }
                guard self.value != nextValue else { continue }
                self.isApplyingStoreUpdate = true
                self.value = nextValue
                self.isApplyingStoreUpdate = false
            }
        }
    }

    isolated deinit {
        task?.cancel()
    }
}

public extension Store {
    func scope<Value: Equatable & Sendable>(
        _ selector: Fluxor.Selector<State, Value>,
        send action: @escaping (Value) -> any Action
    ) -> StoreProjection<State, Environment, Value> {
        StoreProjection(store: self, selector: selector, send: action)
    }
}
