/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A `StoreInterceptor` to use in unit tests, to assert specific `Action`s are dispatched.
public class TestStoreInterceptor<State>: StoreInterceptor {
    public private(set) var dispatchedActionsAndStates: [Storage] = []

    public init() {}

    public func actionDispatched(action: Action, oldState: State, newState: State) {
        dispatchedActionsAndStates.append(.init(action: action, oldState: oldState, newState: newState))
    }

    public struct Storage {
        public let action: Action
        public let oldState: State
        public let newState: State
    }
}
