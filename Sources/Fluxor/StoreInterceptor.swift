/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which intercepts all `Action`s and the  `State` changes happening in a `Store`.
public protocol StoreInterceptor {
    associatedtype State
    /// The function called when an `Action` is dispatched on a `Store`.
    func actionDispatched(action: Action, oldState: State, newState: State)
}

/// A type-erased `StoreInterceptor` used to store all `StoreInterceptor`s in an array in the `Store`.
internal struct AnyStoreInterceptor<State>: StoreInterceptor {
    private let _actionDispatched: (Action, State, State) -> Void

    init<S: StoreInterceptor>(_ storeInterceptor: S) where S.State == State {
        _actionDispatched = storeInterceptor.actionDispatched
    }

    func actionDispatched(action: Action, oldState: State, newState: State) {
        _actionDispatched(action, oldState, newState)
    }
}
