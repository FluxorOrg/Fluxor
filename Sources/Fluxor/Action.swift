//
//  Action.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 18/09/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Foundation

public protocol Action: Encodable {
    func encode(with encoder: JSONEncoder) -> Data?
}

public extension Action where Self: Encodable {
    func encode(with encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
