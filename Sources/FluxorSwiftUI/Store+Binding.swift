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
        -> StaticTemplateValueBinding<State, Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    public func binding<Value, UpdateValue>(get selector: Selector<State, Value>,
                                            set actionTemplateForValue: @escaping (Value) -> ActionTemplate<UpdateValue>)
        -> DynamicValueBinding<State, Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplateForValue: actionTemplateForValue)
    }
}
