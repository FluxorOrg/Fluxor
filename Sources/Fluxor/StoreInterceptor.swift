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
struct AnyStoreInterceptor<State>: StoreInterceptor {
    private let _actionDispatched: (Action, State, State) -> Void

    init<S: StoreInterceptor>(_ storeInterceptor: S) where S.State == State {
        _actionDispatched = storeInterceptor.actionDispatched
    }

    func actionDispatched(action: Action, oldState: State, newState: State) {
        _actionDispatched(action, oldState, newState)
    }
}

/// A `StoreInterceptor` to use in unit tests, to assert specific `Action`s are dispatched.
public class TestStoreInterceptor<State>: StoreInterceptor {
    public private(set) var dispatchedActionsAndStates: [(action: Action, oldState: State, newState: State)] = []

    public init() {}

    public func actionDispatched(action: Action, oldState: State, newState: State) {
        dispatchedActionsAndStates.append((action, oldState, newState))
    }
}
