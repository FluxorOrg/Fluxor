/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which intercepts all `Action`s and the  `State` changes happening in a `Store`.
public protocol Interceptor {
    associatedtype State
    /// The function called when an `Action` is dispatched on a `Store`.
    func actionDispatched(action: Action, oldState: State, newState: State)
}

/// A type-erased `Interceptor` used to store all `Interceptor`s in an array in the `Store`.
internal struct AnyInterceptor<State>: Interceptor {
    private let _actionDispatched: (Action, State, State) -> Void

    init<I: Interceptor>(_ interceptor: I) where I.State == State {
        _actionDispatched = interceptor.actionDispatched
    }

    func actionDispatched(action: Action, oldState: State, newState: State) {
        _actionDispatched(action, oldState, newState)
    }
}
