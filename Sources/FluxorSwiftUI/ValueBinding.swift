/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public class ValueBinding<State: Encodable, Value>: ObservableObject {
    public var value: Value { store.selectCurrent(selector) }
    public lazy var binding: Binding<Value> = {
        Binding(get: { self.value }, set: update)
    }()

    private let store: Fluxor.Store<State>
    private let selector: Fluxor.Selector<State, Value>
    private let actionTemplate: ActionTemplate<Value>

    public init(store: Fluxor.Store<State>,
                selector: Fluxor.Selector<State, Value>,
                actionTemplate: ActionTemplate<Value>) {
        self.store = store
        self.selector = selector
        self.actionTemplate = actionTemplate
    }

    public func update(value: Value) {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction(payload: value))
    }
}
