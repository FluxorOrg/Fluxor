/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor

extension Store {
    public func binding<Value>(selector: Fluxor.Selector<State, Value>,
                               actionTemplate: ActionTemplate<Value>) -> ValueBinding<State, Value> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    public func observe<Value>(selector: Fluxor.Selector<State, Value>) -> ObservableValue<State, Value> {
        return .init(store: self, selector: selector)
    }
}
