/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor

extension Store {
    public func binding<Value, UpdateValue>(get selector: Fluxor.Selector<State, Value>,
                                            set actionTemplate: ActionTemplate<UpdateValue>)
        -> ValueBinding<State, Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    public func observe<Value>(_ selector: Fluxor.Selector<State, Value>) -> ObservableValue<State, Value> {
        return .init(store: self, selector: selector)
    }
}
