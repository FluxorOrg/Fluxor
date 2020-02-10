/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation.NSData

/**
 An event happening in an application.

 `Action`s are dispatched on the `Store`.
 */
public protocol Action: Encodable {
    /**
     To enable encoding of the `Action` this helper function is needed.

     `JSONEncoder` can't encode a value an `Encodable` type unless it has the specific type.
         By using an `extension` of the `Action` we have this specific type and can encode it.
     */
    func encode(with encoder: JSONEncoder) -> Data?
}

public extension Action {
    func encode(with encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}

/**
 Creates an `ActionCreator` with the specified `id` which can't hold a payload.
 */
public func createActionCreator(id: String) -> ActionCreator {
    return ActionCreator(id: id)
}

/**
 Creates an `ActionCreatorWithPayload` with the specified `id` and `payloadType`.

 - Parameter payloadType: The type the payload of the `Action` must have
 */
public func createActionCreator<Payload>(id: String, payloadType: Payload.Type) -> ActionCreatorWithPayload<Payload> {
    return ActionCreatorWithPayload(id: id)
}

/// A creator for creating `AnonymousAction`s
public struct ActionCreator {
    public let id: String

    /**
     Creates an `AnonymousAction` with the `ActionCreator`s `id`.
     */
    public func createAction() -> AnonymousAction {
        return AnonymousAction(id: id)
    }
}

/// A creator for creating `AnonymousActionWithPayload`s
public struct ActionCreatorWithPayload<Payload: Encodable> {
    public let id: String

    /**
     Creates an `AnonymousAction` with the `ActionCreator`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousActionWithPayload` with
     */
    public func createAction(payload: Payload) -> AnonymousActionWithPayload<Payload> {
        return AnonymousActionWithPayload(id: id, payload: payload)
    }
}

/// An `Action` with an identifier.
public protocol IdentifiableAction: Action {
    var id: String { get }
}

/// An anonymous `Action` without payload.
public struct AnonymousAction: IdentifiableAction {
    public let id: String

    public func wasCreated(by actionCreator: ActionCreator) -> Bool {
        return actionCreator.id == id
    }
}

/// An anonymous `Action` with a payload.
public struct AnonymousActionWithPayload<Payload: Encodable>: IdentifiableAction {
    public let id: String
    public let payload: Payload

    public func wasCreated(by actionCreator: ActionCreatorWithPayload<Payload>) -> Bool {
        return actionCreator.id == id
    }
}
