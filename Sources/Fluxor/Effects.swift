/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine

/**
 A side effect that happens as a response to a dispatched `Action`.

 An `Effect` can give a new `Action` to dispatch (a `dispatching` effect) or nothing (a `nonDispatching` effect).
 */
public enum Effect {
    /// An `Effect` that publishes an `Action` to dispatch.
    case dispatching(_ publisher: (AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never>)
    /// An `Effect` that handles the action but doesn't publish a new `Action`.
    case nonDispatching(_ cancellable: (AnyPublisher<Action, Never>) -> AnyCancellable)
}

/// A collection of `Effect`s.
public protocol Effects {
    /// The `Effect`s to register on the `Store`.
    var effects: [Effect] { get }
}

public extension Effects {
    var effects: [Effect] {
        Mirror(reflecting: self).children.compactMap { $0.value as? Effect }
    }
}
