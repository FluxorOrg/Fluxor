/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// An event happening in an application.
public protocol Action: Sendable {}

/// Optional metadata for improving logs and diagnostics.
public protocol ActionMetadataProvider {
    static var fluxorActionName: String { get }
}

public extension ActionMetadataProvider {
    static var fluxorActionName: String { String(describing: Self.self) }
}

/// An `Action` which can encode itself for logging.
public protocol EncodableAction: Action, Encodable {
    func encode(with encoder: JSONEncoder) throws -> Data
}

public extension EncodableAction {
    func encode(with encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

public enum ActionMetadata {
    public static func name(of action: any Action) -> String {
        if let provider = type(of: action) as? any ActionMetadataProvider.Type {
            provider.fluxorActionName
        } else {
            String(describing: type(of: action))
        }
    }
}
