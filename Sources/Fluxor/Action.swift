/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import Foundation.NSData

/**
 An event happening in an application.

 `Action`s are dispatched on the `Store`.
 */
public protocol Action: Encodable {
    /**
     To enable encoding of the `Action` this helper function is needed.

     `JSONEncoder` can't encode an `Encodable` type unless it has the specific type.
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
 Creates an `ActionCreatorWithoutPayload` with the specified `id`.
 */
public func createActionCreator(id: String) -> ActionCreatorWithoutPayload {
    return ActionCreatorWithoutPayload(id: id)
}

/**
 Creates an `ActionCreatorWithEncodablePayload` with the specified `id` and `payloadType`.

 The `payloadType` must be `Encodable`.

 - Parameter payloadType: The type the payload of the `Action` must have
 */
public func createActionCreator<Payload: Encodable>(id: String, payloadType: Payload.Type)
    -> ActionCreatorWithEncodablePayload<Payload> {
    return ActionCreatorWithEncodablePayload(id: id)
}

/**
 Creates an `ActionCreatorWithCustomPayload` with the specified `id` and `payloadType`.

 - Parameter payloadType: The type the payload of the `Action` must have
 */
public func createActionCreator<Payload>(id: String, payloadType: Payload.Type)
    -> ActionCreatorWithCustomPayload<Payload> {
    return ActionCreatorWithCustomPayload(id: id)
}

/// A type creating `AnonymousAction`s.
public protocol ActionCreator {
    var id: String { get }
}

/// A creator for creating `AnonymousAction`s
public struct ActionCreatorWithoutPayload: ActionCreator {
    public let id: String

    /**
     Creates an `AnonymousActionWithoutPayload` with the `ActionCreator`s `id`.
     */
    public func createAction() -> AnonymousActionWithoutPayload {
        return AnonymousActionWithoutPayload(id: id)
    }
}

/// A creator for creating `AnonymousActionWithEncodablePayload`s
public struct ActionCreatorWithEncodablePayload<Payload: Encodable>: ActionCreator {
    public let id: String

    /**
     Creates an `AnonymousActionWithEncodablePayload` with the `ActionCreator`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousActionWithEncodablePayload` with
     */
    public func createAction(payload: Payload) -> AnonymousActionWithEncodablePayload<Payload> {
        return AnonymousActionWithEncodablePayload(id: id, payload: payload)
    }
}

/// A creator for creating `AnonymousActionWithCustomPayload`s
public struct ActionCreatorWithCustomPayload<Payload>: ActionCreator {
    public let id: String

    /**
     Creates an `AnonymousActionWithCustomPayload` with the `ActionCreator`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousActionWithCustomPayload` with
     */
    public func createAction(payload: Payload) -> AnonymousActionWithCustomPayload<Payload> {
        return AnonymousActionWithCustomPayload(id: id, payload: payload)
    }
}

/// An `Action` with an identifier.
public protocol AnonymousAction: Action {
    var id: String { get }
    /**
     Check if the `AnonymousAction` was created by a given `ActionCreator`.

     - Parameter actionCreator: The `ActionCreator` to check
     */
    func wasCreated(by actionCreator: ActionCreator) -> Bool

    /**
     Cast the action to an `AnonymousActionWithoutPayload` if it was created by the given `ActionCreatorWithoutPayload`.

     - Parameter actionCreator: The `ActionCreatorWithoutPayload` to match on
     */
    func asCreated(by actionCreator: ActionCreatorWithoutPayload) -> AnonymousActionWithoutPayload?

    /**
     Cast the action to an `AnonymousActionWithEncodablePayload`
     if it was created by the given `ActionCreatorWithEncodablePayload`.

     - Parameter actionCreator: The `ActionCreatorWithEncodablePayload` to match on
     */
    func asCreated<Payload>(by actionCreator: ActionCreatorWithEncodablePayload<Payload>)
        -> AnonymousActionWithEncodablePayload<Payload>?

    /**
     Cast the action to an `AnonymousActionWithCustomPayload`
     if it was created by the given `ActionCreatorWithCustomPayload`.

     - Parameter actionCreator: The `ActionCreatorWithCustomPayload` to match on
     */
    func asCreated<Payload>(by actionCreator: ActionCreatorWithCustomPayload<Payload>)
        -> AnonymousActionWithCustomPayload<Payload>?
}

public extension AnonymousAction {
    func wasCreated(by actionCreator: ActionCreator) -> Bool {
        return actionCreator.id == id
    }

    func asCreated(by actionCreator: ActionCreatorWithoutPayload) -> AnonymousActionWithoutPayload? {
        return castIfCreated(by: actionCreator)
    }

    func asCreated<Payload>(by actionCreator: ActionCreatorWithEncodablePayload<Payload>)
        -> AnonymousActionWithEncodablePayload<Payload>? {
        return castIfCreated(by: actionCreator)
    }

    func asCreated<Payload>(by actionCreator: ActionCreatorWithCustomPayload<Payload>)
        -> AnonymousActionWithCustomPayload<Payload>? {
        return castIfCreated(by: actionCreator)
    }

    private func castIfCreated<T>(by actionCreator: ActionCreator) -> T? {
        guard wasCreated(by: actionCreator) else { return nil }
        return self as? T
    }
}

/// An anonymous `Action` without payload.
public struct AnonymousActionWithoutPayload: AnonymousAction {
    public let id: String
}

/// An anonymous `Action` with an `Encodable` payload.
public struct AnonymousActionWithEncodablePayload<Payload: Encodable>: AnonymousAction {
    public let id: String
    public let payload: Payload
}

/// An anonymous `Action` without an non-`Encodable` payload (eg. a tuple).
public struct AnonymousActionWithCustomPayload<Payload>: AnonymousAction {
    public let id: String
    public let payload: Payload
    private var encodablePayload: [String: AnyEncodable] {
        let mirror = Mirror(reflecting: payload)
        let dict = mirror.children.reduce(into: [String: AnyEncodable]()) {
            $0[$1.label!] = AnyEncodable($1.value)
        }
        return dict
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(encodablePayload, forKey: .payload)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case payload
    }
}
