/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public class ValueBinding<Value, UpdateValue>: ObservableObject {
    public var value: Value { storeSelectCurrent() }
    internal let storeDispatch: (Action) -> Void
    internal let storeSelectCurrent: () -> Value

    public init<State: Encodable>(store: Store<State>, selector: Fluxor.Selector<State, Value>) {
        self.storeSelectCurrent = { store.selectCurrent(selector) }
        self.storeDispatch = store.dispatch(action:)
    }

    fileprivate func update(value: UpdateValue, with actionTemplate: ActionTemplate<UpdateValue>) {
        objectWillChange.send()
        storeDispatch(actionTemplate.createAction(payload: value))
    }
}

public extension ValueBinding where UpdateValue == Void {
    fileprivate func update(with actionTemplate: ActionTemplate<UpdateValue>) {
        objectWillChange.send()
        storeDispatch(actionTemplate.createAction())
    }
}

public class StaticTemplateValueBinding<Value, UpdateValue>: ValueBinding<Value, UpdateValue> {
    private let actionTemplate: ActionTemplate<UpdateValue>

    public init<State: Encodable>(store: Store<State>,
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

public class DynamicValueBinding<Value, UpdateValue>: ValueBinding<Value, UpdateValue> {
    private let actionTemplate: (Value) -> ActionTemplate<UpdateValue>

    public init<State: Encodable>(store: Store<State>,
                                  selector: Fluxor.Selector<State, Value>,
                                  actionTemplate: @escaping (Value) -> ActionTemplate<UpdateValue>) {
        self.actionTemplate = actionTemplate
        super.init(store: store, selector: selector)
    }
}

public extension DynamicValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: update)
    }

    func update(value: UpdateValue) {
        super.update(value: value, with: actionTemplate(value))
    }
}

public extension DynamicValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }

    func update() {
        super.update(with: actionTemplate(value))
    }
}

public extension DynamicValueBinding where Value == Bool, UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }

    func update(value: Value) {
        super.update(with: actionTemplate(value))
    }
}
