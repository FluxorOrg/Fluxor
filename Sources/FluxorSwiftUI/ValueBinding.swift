/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public class ValueBinding<State: Encodable, Value>: ObservableValue<State, Value> {
    public override var value: Value { store.selectCurrent(selector) }
    public lazy var binding: Binding<Value> = {
        Binding(get: { self.value }, set: update)
    }()

    private let actionTemplate: ActionTemplate<Value>

    public init(store: Fluxor.Store<State>,
                selector: Fluxor.Selector<State, Value>,
                actionTemplate: ActionTemplate<Value>) {
        self.actionTemplate = actionTemplate
        super.init(store: store, selector: selector)
    }

    public func update(value: Value) {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction(payload: value))
    }
}
