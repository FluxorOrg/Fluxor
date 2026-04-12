/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import SwiftUI

@propertyWrapper
public struct FluxorBinding<StoreState: Sendable, StoreEnvironment: Sendable, Value: Equatable & Sendable>: @MainActor DynamicProperty {
    @Environment(Store<StoreState, StoreEnvironment>.self) private var store: Store<StoreState, StoreEnvironment>
    @FluxorSelect<StoreState, StoreEnvironment, Value> private var value: Value

    private let action: (Value) -> any Action

    public init(
        _ selector: Fluxor.Selector<StoreState, Value>,
        send action: @escaping (Value) -> any Action
    ) {
        _value = FluxorSelect<StoreState, StoreEnvironment, Value>(selector)
        self.action = action
    }

    @MainActor
    public var wrappedValue: Value {
        value
    }

    @MainActor
    public var projectedValue: Binding<Value> {
        Binding(
            get: { value },
            set: { store.send(erasing: action($0)) }
        )
    }
}
