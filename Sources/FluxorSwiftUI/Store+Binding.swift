/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import SwiftUI

public extension Store {
    func binding<Value>(
        get selector: Fluxor.Selector<State, Value>,
        send action: @escaping (Value) -> any Action
    ) -> Binding<Value> {
        Binding(
            get: { self.current(selector) },
            set: { self.send(erasing: action($0)) }
        )
    }
}
