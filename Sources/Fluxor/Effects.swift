/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine

public typealias ActionPublisher = Published<Action>.Publisher

/// A collection of effects based on the given `ActionPublisher`.
public protocol Effects: AnyObject {
    var effects: [Effect] { get }
    /**
     Initializes the `Effects` with an `ActionPublisher`.

     - Parameter actions: The `ActionPublisher` for the `Effect`s to listen to
     */
    init(_ actions: ActionPublisher)
}

/**
 Something that happens as a response to a dispatched `Action`.

 An `Effect` can give a new `Action` to dispatch (a `dispatching` effect) or nothing (a `nonDispatching` effect).
 */
public enum Effect {
    /// An `Effect` that gives an `Action` to dispatch.
    case dispatching(_ publisher: AnyPublisher<Action, Never>)
    /// An `Effect` that handles the action but doesn't give an `Action`.
    case nonDispatching(_ cancellable: AnyCancellable)
}
