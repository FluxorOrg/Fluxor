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
        .init(get: { self.value }, set: { _ in self.toggle() })
    }

    func toggle() {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction())
    }
}

public class DynamicValueBinding<State: Encodable, Value, UpdateValue>: ObservableValue<State, Value> {
    public override var value: Value { store.selectCurrent(selector) }
    private let actionTemplateForValue: (Value) -> ActionTemplate<UpdateValue>

    public init(store: Fluxor.Store<State>,
                selector: Fluxor.Selector<State, Value>,
                actionTemplateForValue: @escaping (Value) -> ActionTemplate<UpdateValue>) {
        self.actionTemplateForValue = actionTemplateForValue
        super.init(store: store, selector: selector)
    }
}

public extension DynamicValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: update)
    }

    func update(value: UpdateValue) {
        objectWillChange.send()
        store.dispatch(action: actionTemplateForValue(value).createAction(payload: value))
    }
}

public extension DynamicValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.toggle() })
    }

    func toggle() {
        objectWillChange.send()
        store.dispatch(action: actionTemplateForValue(value).createAction())
    }
}

public extension DynamicValueBinding where Value == Bool, UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.toggle() })
    }

    func update(value: Value) {
        objectWillChange.send()
        store.dispatch(action: actionTemplateForValue(value).createAction())
    }
}
