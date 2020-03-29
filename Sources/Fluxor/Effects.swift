/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine

public typealias ActionPublisher = Published<Action>.Publisher

/**
 A side effect that happens as a response to a dispatched `Action`.

 An `Effect` can give a new `Action` to dispatch (a `dispatching` effect) or nothing (a `nonDispatching` effect).
 */
public enum Effect {
    /// An `Effect` that publishes an `Action` to dispatch.
    case dispatching(_ publisher: AnyPublisher<Action, Never>)
    /// An `Effect` that handles the action but doesn't publish a new `Action`.
    case nonDispatching(_ cancellable: AnyCancellable)
}

/// A collection of `EffectCreator`s the `Store` can use to register `Effect`s.
public protocol Effects: AnyObject {
    /// The `EffectCreator`s to invoke to create `Effect`s to register on the `Store`.
    var effectCreators: [EffectCreator] { get }
}

public extension Effects {
    var effectCreators: [EffectCreator] {
        Mirror(reflecting: self).children.compactMap { $0.value as? EffectCreator }
    }
}

/**
 Creates a `DispathingEffectCreator` from the given creator closure.

 A dispatching `Effect` gives a new `Action` to dispatch on the store in the future.

 - Parameter createPublisher: The closure to create an `AnyPublisher<Action, Never>` for the `Effect`
 */
public func createEffectCreator(_ createPublisher: @escaping (ActionPublisher) -> AnyPublisher<Action, Never>)
    -> EffectCreator {
    return DispathingEffectCreator(createPublisher: createPublisher)
}

/**
 Creates a `NonDispathingEffectCreator` from the given creator closure.

 - Parameter createCancellable: The closure to create an `AnyCancellable` for the `Effect`
 */
public func createEffectCreator(_ createCancellable: @escaping (ActionPublisher) -> AnyCancellable) -> EffectCreator {
    return NonDispathingEffectCreator(createCancellable: createCancellable)
}

/// A type creating `Effect`s.
public protocol EffectCreator {
    /**
     Creates an `Effect` based on the given `ActionPublisher`.

     - Parameter actionPublisher: The `ActionPublisher` to create the `Effect` from
     */
    func createEffect(actionPublisher: ActionPublisher) -> Effect
}

/// A creator for creating a dispatching `Effect`.
public struct DispathingEffectCreator: EffectCreator {
    let createPublisher: (ActionPublisher) -> AnyPublisher<Action, Never>

    public func createEffect(actionPublisher: ActionPublisher) -> Effect {
        return .dispatching(createPublisher(actionPublisher))
    }
}

/// A creator for creating a non dispatching `Effect`.
public struct NonDispathingEffectCreator: EffectCreator {
    let createCancellable: (ActionPublisher) -> AnyCancellable

    public func createEffect(actionPublisher: ActionPublisher) -> Effect {
        return .nonDispatching(createCancellable(actionPublisher))
    }
}
