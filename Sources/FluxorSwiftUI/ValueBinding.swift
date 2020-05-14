/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public class ValueBinding<State: Encodable, Value, UpdateValue>: ObservableValue<State, Value> {
    public override var value: Value { store.selectCurrent(selector) }
    private let actionTemplate: ActionTemplate<UpdateValue>

    public init(store: Fluxor.Store<State>,
                selector: Fluxor.Selector<State, Value>,
                actionTemplate: ActionTemplate<UpdateValue>) {
        self.actionTemplate = actionTemplate
        super.init(store: store, selector: selector)
    }
}

public extension ValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: update)
    }
    
    func update(value: UpdateValue) {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction(payload: value))
    }
}

public extension ValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }
    
    func update() {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction())
    }
}
