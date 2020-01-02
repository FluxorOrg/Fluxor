/**
* Fluxor
*  Copyright (c) Morten Bjerg Gregersen 2020
*  MIT license, see LICENSE file for details
*/

import Foundation

public protocol Action: Encodable {
    func encode(with encoder: JSONEncoder) -> Data?
}

public extension Action where Self: Encodable {
    func encode(with encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
