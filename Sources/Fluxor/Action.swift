/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import AnyCodable
import Foundation

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
 A template for creating `Action`s.

 The template can have a `Payload`type which is used when creating an actual `Action` from the template.
 */
public struct ActionTemplate<Payload> {
    let id: String
    let payloadType: Payload.Type

    public init(id: String, payloadType: Payload.Type) {
        self.id = id
        self.payloadType = payloadType
    }

    /**
     Creates an `AnonymousAction` with the `ActionCreator`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousAction` with
     */
    public func createAction(payload: Payload) -> AnonymousAction<Payload> {
        return .init(id: id, payload: payload)
    }
}

public extension ActionTemplate where Payload == Void {
    init(id: String) {
        self.init(id: id, payloadType: Payload.self)
    }

    /**
     Creates an `AnonymousAction` with the `ActionCreator`s `id`.
     */
    func createAction() -> AnonymousAction<Payload> {
        return .init(id: id, payload: ())
    }
}

internal protocol IdentifiableAction: Action {
    var id: String { get }
}

/// An `Action` with an identifier. Created from `ActionTemplate`s.
public struct AnonymousAction<Payload>: IdentifiableAction {
    public let id: String
    public private(set) var payload: Payload

    /**
     Check if the `AnonymousAction` was created from a given `ActionTemplate`.

     - Parameter actionTemplate: The `ActionTemplate` to check
     */
    public func wasCreated(from actionTemplate: ActionTemplate<Payload>) -> Bool {
        return actionTemplate.id == id
    }
}

extension AnonymousAction: Encodable {
    private var encodablePayload: [String: AnyCodable] {
        let mirror = Mirror(reflecting: payload)
        let dict = mirror.children.reduce(into: [String: AnyCodable]()) {
            $0[$1.label!] = AnyCodable($1.value)
        }
        return dict
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        guard type(of: payload) != Void.self else { return }
        if let payload = payload as? Encodable {
            try container.encode(AnyCodable(payload), forKey: .payload)
        } else {
            try container.encode(encodablePayload, forKey: .payload)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case payload
    }
}
