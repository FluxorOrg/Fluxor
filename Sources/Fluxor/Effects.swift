/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

#if canImport(Combine)
import Combine
#else
import OpenCombine
#endif

/**
 A side effect that happens as a response to a dispatched `Action`.

 An `Effect` can:
 - give a new `Action` to dispatch (a `dispatchingOne` effect)
 - give an array of new `Action`s to dispatch (a `dispatchingMultiple` effect)
 - give nothing (a `nonDispatching` effect)
 */
public enum Effect<Environment> {
    /// An `Effect` that publishes an `Action` to dispatch.
    case dispatchingOne(_ publisher: (AnyPublisher<Action, Never>, Environment) -> AnyPublisher<Action, Never>)
    /// An `Effect` that publishes multiple `Action`s to dispatch.
    case dispatchingMultiple(_ publisher: (AnyPublisher<Action, Never>, Environment) -> AnyPublisher<[Action], Never>)
    /// An `Effect` that handles the action but doesn't publish a new `Action`.
    case nonDispatching(_ cancellable: (AnyPublisher<Action, Never>, Environment) -> AnyCancellable)
}

/// A collection of `Effect`s.
public protocol Effects {
    /// The environment set up in the `Store` passed to every `Effect`.
    associatedtype Environment
    /// The `Effect`s to register on the `Store`.
    var enabledEffects: [Effect<Environment>] { get }
    /// The identifier for the `Effects`
    static var id: String { get }
}

public extension Effects {
    var enabledEffects: [Effect<Environment>] {
        Mirror(reflecting: self).children.compactMap { $0.value as? Effect<Environment> }
    }

    static var id: String { .init(describing: Self.self) }
}
