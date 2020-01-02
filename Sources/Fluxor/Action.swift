/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/**
 An event happening in an application.

 `Action`s are dispatched on the `Store`. They often contain a payload.
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
