/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import SwiftUI

@MainActor
private final class ProjectionBox<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable> {
    private var storeIdentifier: ObjectIdentifier?
    private var selectorIdentifier: UUID?

    var projection: StoreProjection<StoreState, StoreEnvironment, Value>?

    func connect(
        store: Store<StoreState, StoreEnvironment>,
        selector: Fluxor.Selector<StoreState, Value>,
        action: @escaping (Value) -> any Action
    ) {
        let nextStoreIdentifier = ObjectIdentifier(store)
        guard storeIdentifier != nextStoreIdentifier || selectorIdentifier != selector.id || projection == nil else { return }

        storeIdentifier = nextStoreIdentifier
        selectorIdentifier = selector.id
        projection = store.scope(selector, send: action)
    }
}

@propertyWrapper
public struct FluxorProjection<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable>: @MainActor DynamicProperty {
    @Environment(Store<StoreState, StoreEnvironment>.self) private var store: Store<StoreState, StoreEnvironment>
    @State private var box = ProjectionBox<StoreState, StoreEnvironment, Value>()

    private let selector: Fluxor.Selector<StoreState, Value>
    private let action: (Value) -> any Action

    public init(
        _ selector: Fluxor.Selector<StoreState, Value>,
        send action: @escaping (Value) -> any Action
    ) {
        self.selector = selector
        self.action = action
    }

    @MainActor
    public var wrappedValue: StoreProjection<StoreState, StoreEnvironment, Value> {
        box.projection ?? store.scope(selector, send: action)
    }

    @MainActor
    public var projectedValue: StoreProjection<StoreState, StoreEnvironment, Value> {
        wrappedValue
    }

    @MainActor
    public mutating func update() {
        box.connect(store: store, selector: selector, action: action)
    }
}
