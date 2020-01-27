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
 Creates an `Action` without payload.
 */
public func createAction(id: String) -> AnonymousAction {
    return AnonymousAction(id: id)
}

/**
 Creates an `Action` with a payload.

 - Parameter payload: The payload to create an `Action` with
 */
public func createAction<Payload: Encodable>(id: String, payload: Payload) -> AnonymousActionWithPayload<Payload> {
    return AnonymousActionWithPayload(id: id, payload: payload)
}

/// An `Action` with an identifier.
public protocol IdentifiableAction: Action {
    var id: String { get }
}

/// An anonymous `Action` without payload.
public struct AnonymousAction: IdentifiableAction {
    public let id: String
}

/// An anonymous `Action` with a payload.
public struct AnonymousActionWithPayload<Payload: Encodable>: IdentifiableAction {
    public let id: String
    let payload: Payload
}
