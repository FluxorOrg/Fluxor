/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A `StoreInterceptor` to use in unit tests, to assert specific `Action`s are dispatched.
public class TestStoreInterceptor<State>: StoreInterceptor {
    public private(set) var dispatchedActionsAndStates: [(action: Action, oldState: State, newState: State)] = []

    public init() {}

    public func actionDispatched(action: Action, oldState: State, newState: State) {
        dispatchedActionsAndStates.append((action, oldState, newState))
    }
}
