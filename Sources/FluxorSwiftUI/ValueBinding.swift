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
        objectWillChange.send()
        let actionTemplate = actionTemplateForValue(value)
        let action = actionCreator(actionTemplate)
        storeDispatch(action)
    }
}

public extension ValueBinding where UpdateValue == Void {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: { _ in self.update() })
    }

    func update() {
        update(value: value) { $0.createAction() }
    }
}

public extension ValueBinding where UpdateValue == Value {
    var binding: Binding<Value> {
        .init(get: { self.value }, set: update)
    }

    func update(value: UpdateValue) {
        update(value: value) { $0.createAction(payload: value) }
    }
}

public extension ValueBinding where Value == Bool, UpdateValue == Void {
    func update(value: Value) {
        update(value: value) { $0.createAction() }
    }
}
