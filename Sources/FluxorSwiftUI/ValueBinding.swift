/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public extension Store {
    func binding<Value, UpdateValue>(get selector: Fluxor.Selector<State, Value>,
                                     send actionTemplate: ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    func binding(get selector: Fluxor.Selector<State, Bool>,
                 enable enableActionTemplate: ActionTemplate<Void>,
                 disable disableActionTemplate: ActionTemplate<Void>)
        -> ValueBinding<Bool, Void> {
        return .init(store: self, selector: selector) { $0 ? enableActionTemplate : disableActionTemplate }
    }

    func binding<Value, UpdateValue>(get selector: Fluxor.Selector<State, Value>,
                                     send actionTemplate: @escaping (Value) -> ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplateForValue: actionTemplate)
    }
}

public class ValueBinding<Value, UpdateValue> {
    public var current: Value { storeSelectCurrent() }
    private let storeDispatch: (Action) -> Void
    private let storeSelectCurrent: () -> Value
    private let actionTemplateForValue: (Value) -> ActionTemplate<UpdateValue>

    public init<State: Encodable>(store: Store<State>,
                                  selector: Fluxor.Selector<State, Value>,
                                  actionTemplateForValue: @escaping (Value) -> ActionTemplate<UpdateValue>) {
        self.storeSelectCurrent = { store.selectCurrent(selector) }
        self.storeDispatch = store.dispatch(action:)
        self.actionTemplateForValue = actionTemplateForValue
    }

    public convenience init<State: Encodable>(store: Store<State>,
                                              selector: Fluxor.Selector<State, Value>,
                                              actionTemplate: ActionTemplate<UpdateValue>) {
        self.init(store: store, selector: selector, actionTemplateForValue: { _ in actionTemplate })
    }

    private func update(value: Value, with actionCreator: (ActionTemplate<UpdateValue>) -> Action) {
        let actionTemplate = actionTemplateForValue(value)
        let action = actionCreator(actionTemplate)
        storeDispatch(action)
    }
}

public extension ValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.current }, set: update)
    }

    func update() {
        update(value: current)
    }

    private func update(value: Value) {
        update(value: value) { $0.createAction() }
    }
}

public extension ValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.current }, set: update)
    }

    func update(value: UpdateValue) {
        update(value: value) { $0.createAction(payload: value) }
    }
}

public extension ValueBinding where Value == Bool, UpdateValue == Bool {
    func toggle() {
        update(value: !current)
    }

    func enable() {
        update(value: true)
    }

    func disable() {
        update(value: false)
    }
}

public extension ValueBinding where Value == Bool, UpdateValue == Void {
    func toggle() {
        update(value: !current)
    }

    func enable() {
        update(value: true)
    }

    func disable() {
        update(value: false)
    }

    func update(value: Value) {
        update(value: value) { $0.createAction() }
    }
}
