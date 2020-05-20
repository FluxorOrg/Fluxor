/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor

extension Store {
    public func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return .init(store: self, selector: selector)
    }

    public func binding<Value, UpdateValue>(get selector: Selector<State, Value>,
                                            set actionTemplate: ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    public func binding(get selector: Selector<State, Bool>,
                        enable enableActionTemplate: ActionTemplate<Void>,
                        disable disableActionTemplate: ActionTemplate<Void>)
        -> ValueBinding<Bool, Void> {
        return .init(store: self, selector: selector) { $0 ? enableActionTemplate : disableActionTemplate }
    }

    public func binding<Value, UpdateValue>(get selector: Selector<State, Value>,
                                            set actionTemplate: @escaping (Value) -> ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplateForValue: actionTemplate)
    }
}
