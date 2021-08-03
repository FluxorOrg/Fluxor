/*
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Fluxor
import SwiftUI

public extension Store {
    /**
     Creates a `ValueBinding` from the given `Selector` and `ActionTemplate`.

      When the value is updated an `Action`, created from the `ActionTemplate`, is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter actionTemplate: The `ActionTemplate` to use for dispatching an `Action` when the value changes
     - Returns: A `Binding` based on the given `Selector` and `ActionTemplate`
     */
    func binding<Value>(get selector: Fluxor.Selector<State, Value>,
                        send actionTemplate: ActionTemplate<Value>) -> Binding<Value> {
        .init(get: { self.selectCurrent(selector) },
              set: { self.dispatch(action: actionTemplate.createAction(payload: $0)) })
    }

    /**
     Creates a `Binding` from the given `Selector` and `ActionTemplate`s for enabling and disabling the value.

     When the value is enabled/disabled, an `Action`, created from one of the `ActionTemplate`s,
     is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter enableActionTemplate: The `ActionTemplate` to use for dispatching an `Action`
                                       when the value should be enabled
     - Parameter disableActionTemplate: The `ActionTemplate` to use for dispatching an `Action`
                                        when the value should be disabled
     - Returns: A `Binding` based on the given `Selector` and `ActionTemplate`s
     */
    func binding(get selector: Fluxor.Selector<State, Bool>,
                 enable enableActionTemplate: ActionTemplate<Void>,
                 disable disableActionTemplate: ActionTemplate<Void>)
        -> Binding<Bool> {
        return .init(get: { self.selectCurrent(selector) },
                     set: { self.dispatch(action: ($0 ? enableActionTemplate : disableActionTemplate)()) })
    }

    /**
     Creates a `Binding` from the given `Selector` and `ActionTemplate`.

      When the value is updated an `Action` (returned by the closure), is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter action: A closure used to decide which `ActionTemplate` to use
                                 for dispatching an `Action` when the value changes
     - Parameter value: The value used to decide which `ActionTemplate` to use for the update.
                        This can either be the current value or the one used for the update
     - Returns: A `Binding` based on the given `Selector` and `ActionTemplate`
     */
    func binding<Value>(get selector: Fluxor.Selector<State, Value>,
                        send action: @escaping (_ value: Value) -> Action)
        -> Binding<Value> {
        return .init(get: { self.selectCurrent(selector) },
                     set: { self.dispatch(action: action($0)) })
    }
}

#endif
