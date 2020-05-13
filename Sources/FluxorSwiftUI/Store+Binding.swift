/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor

extension Store {
    func binding<Value>(selector: Fluxor.Selector<State, Value>,
                        actionTemplate: ActionTemplate<Value>) -> ValueBinding<State, Value> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }
}
