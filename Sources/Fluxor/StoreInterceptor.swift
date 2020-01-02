/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

public protocol StoreInterceptor {
    associatedtype State
    func actionDispatched(action: Action, oldState: State, newState: State)
}

struct AnyStoreInterceptor<State>: StoreInterceptor {
    private let _actionDispatched: (Action, State, State) -> Void

    init<S: StoreInterceptor>(_ storeInterceptor: S) where S.State == State {
        _actionDispatched = storeInterceptor.actionDispatched
    }

    func actionDispatched(action: Action, oldState: State, newState: State) {
        _actionDispatched(action, oldState, newState)
    }
}

public class TestStoreInterceptor<State>: StoreInterceptor {
    public private(set) var dispatchedActionsAndStates: [(action: Action, oldState: State, newState: State)] = []

    public init() {}

    public func actionDispatched(action: Action, oldState: State, newState: State) {
        dispatchedActionsAndStates.append((action, oldState, newState))
    }
}
