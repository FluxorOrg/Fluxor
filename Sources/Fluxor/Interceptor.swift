/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which observes every action and state transition happening in a store.
@MainActor
public protocol Interceptor {
    associatedtype State

    func actionDispatched(action: any Action, oldState: State, newState: State)
    static var id: String { get }
}

public extension Interceptor {
    static var id: String { String(describing: Self.self) }
}

@MainActor
internal struct AnyInterceptor<State>: Interceptor {
    let originalId: String
    private let actionDispatchedClosure: (any Action, State, State) -> Void

    init<I: Interceptor>(_ interceptor: I) where I.State == State {
        originalId = type(of: interceptor).id
        actionDispatchedClosure = interceptor.actionDispatched
    }

    func actionDispatched(action: any Action, oldState: State, newState: State) {
        actionDispatchedClosure(action, oldState, newState)
    }
}
