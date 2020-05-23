/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor
import SwiftUI

public extension Store {
    /**
     Creates a `ValueBinding` from the given `Selector` and `ActionTemplate`.

      When the value is updated an `Action`, created from the `ActionTemplate`, is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter actionTemplate: The `ActionTemplate` to use for dispatching an `Action` when the value changes
     */
    func binding<Value, UpdateValue>(get selector: Fluxor.Selector<State, Value>,
                                     send actionTemplate: ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplate: actionTemplate)
    }

    /**
     Creates a `ValueBinding` from the given `Selector` and `ActionTemplate`s for enabling and disabling the value.

      When the value is enabled/disabled an `Action`, created from one of the `ActionTemplate`s, is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter enableActionTemplate: The `ActionTemplate` to use for dispatching an `Action` when the value should be enabled
     - Parameter disableActionTemplate: The `ActionTemplate` to use for dispatching an `Action` when the value should be disabled
     */
    func binding(get selector: Fluxor.Selector<State, Bool>,
                 enable enableActionTemplate: ActionTemplate<Void>,
                 disable disableActionTemplate: ActionTemplate<Void>)
        -> ValueBinding<Bool, Void> {
        return .init(store: self, selector: selector) { $0 ? enableActionTemplate : disableActionTemplate }
    }

    /**
     Creates a `ValueBinding` from the given `Selector` and `ActionTemplate`.

      When the value is updated an `Action`, created from the `ActionTemplate` (returned by the closure),
      is dispatched on the `Store`.

     - Parameter selector: The `Selector`s to use for getting the current value
     - Parameter actionTemplate: A closure used to decide which`ActionTemplate` to use
                                 for dispatching an `Action` when the value changes
     - Parameter value: The value used to decide which `ActionTemplate` to use for the update.
                        This can either be the current value or the one used for the update
     */
    func binding<Value, UpdateValue>(get selector: Fluxor.Selector<State, Value>,
                                     send actionTemplate: @escaping (_ value: Value) -> ActionTemplate<UpdateValue>)
        -> ValueBinding<Value, UpdateValue> {
        return .init(store: self, selector: selector, actionTemplateForValue: actionTemplate)
    }
}

public class ValueBinding<Value, UpdateValue> {
    /// The current value. This will change everytime the `State` in the `Store` changes
    public var current: Value { storeSelectCurrent() }
    private let storeDispatch: (Action) -> Void
    private let storeSelectCurrent: () -> Value
    private let actionTemplateForValue: (Value) -> ActionTemplate<UpdateValue>

    /**
     Initializes the `ValueBinding` with a `Selector`, a closure returning an `ActionTemplate`
     and the `Store` from where to select and dispatch `Action`s.

     - Parameter store: The `Store` to select from and dispatch `Action`s
     - Parameter selector: The `Selector`s to use for selecting
     - Parameter actionTemplateForValue: A closure used to decide which`ActionTemplate` to use
                                         for dispatching an `Action` when the value changes
     */
    public init<State: Encodable>(store: Store<State>,
                                  selector: Fluxor.Selector<State, Value>,
                                  actionTemplateForValue: @escaping (Value) -> ActionTemplate<UpdateValue>) {
        self.storeSelectCurrent = { store.selectCurrent(selector) }
        self.storeDispatch = store.dispatch(action:)
        self.actionTemplateForValue = actionTemplateForValue
    }

    /**
     Initializes the `ValueBinding` with a `Selector`, a closure returning an `ActionTemplate`
     and the `Store` from where to select and dispatch `Action`s.

     - Parameter store: The `Store` to select from and dispatch `Action`s
     - Parameter selector: The `Selector`s to use for selecting
     - Parameter actionTemplate: The `ActionTemplate` to use for dispatching an `Action` when the value changes
     */
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
    /// A `Binding` to use in SwiftUI Views. When the View sets the `Binding` it wil automatically dispatch an `Action`.
    var binding: Binding<Value> {
        .init(get: { self.current }, set: update)
    }

    /// Update the value by dispatching an `Action` based on the current value.
    func update() {
        update(value: current)
    }

    private func update(value: Value) {
        update(value: value) { $0.createAction() }
    }
}

public extension ValueBinding where UpdateValue == Value {
    /// A `Binding` to use in SwiftUI Views. When the View sets the `Binding` it wil automatically dispatch an `Action`.
    var binding: Binding<Value> {
        .init(get: { self.current }, set: update)
    }

    /**
     Update the value by dispatching an `Action` with the given value.

     - Parameter value: The value to use for updating
     */
    func update(value: UpdateValue) {
        update(value: value) { $0.createAction(payload: value) }
    }
}

public extension ValueBinding where Value == Bool, UpdateValue == Bool {
    /// Update the value by dispatching an `Action` with the opposite value of the current.
    func toggle() {
        update(value: !current)
    }

    /// Disable the value by dispatching an `Action` with `true` as `payload`.
    func enable() {
        update(value: true)
    }

    /// Disable the value by dispatching an `Action` with `false` as `payload`.
    func disable() {
        update(value: false)
    }
}

public extension ValueBinding where Value == Bool, UpdateValue == Void {
    /// Update the value by dispatching an `Action` with the opposite value of the current.
    func toggle() {
        update(value: !current)
    }

    /// Enable the value by dispatching an `Action` from the `enableActionTemplate`.
    func enable() {
        update(value: true)
    }

    /// Disable the value by dispatching an `Action` from the `disableActionTemplate`.
    func disable() {
        update(value: false)
    }

    /**
     Update the value by dispatching an `Action` with the given value.

     - Parameter value: The value to use for updating
     */
    func update(value: Value) {
        update(value: value) { $0.createAction() }
    }
}
