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
    
    fileprivate func update(value: UpdateValue, with actionTemplate: ActionTemplate<UpdateValue>) {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction(payload: value))
    }
}

public extension ValueBinding where UpdateValue == Void {
    fileprivate func update(with actionTemplate: ActionTemplate<UpdateValue>) {
        objectWillChange.send()
        store.dispatch(action: actionTemplate.createAction())
    }
}

public class StaticTemplateValueBinding<State: Encodable, Value, UpdateValue>: ValueBinding<State, Value, UpdateValue> {
    private let actionTemplate: ActionTemplate<UpdateValue>

    public init(store: Store<State>,
                selector: Fluxor.Selector<State, Value>,
                actionTemplate: ActionTemplate<UpdateValue>) {
        self.actionTemplate = actionTemplate
        super.init(store: store, selector: selector)
    }
}

public extension StaticTemplateValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: update)
    }

    func update(value: UpdateValue) {
        super.update(value: value, with: actionTemplate)
    }
}

public extension StaticTemplateValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }

    func update() {
        super.update(with: actionTemplate)
    }
}

public class DynamicValueBinding<State: Encodable, Value, UpdateValue>: ValueBinding<State, Value, UpdateValue> {
    private let actionTemplateForValue: (Value) -> ActionTemplate<UpdateValue>

    public init(store: Store<State>,
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
        super.update(value: value, with: actionTemplateForValue(value))
    }
}

public extension DynamicValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }

    func update() {
        super.update(with: actionTemplateForValue(value))
    }
}

public extension DynamicValueBinding where Value == Bool, UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update()})
    }

    func update(value: Value) {
        super.update(with: actionTemplateForValue(value))
    }
}
