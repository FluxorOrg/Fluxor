//
//  Action.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 18/09/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import AnyCodable

public protocol Action: Encodable {
    var encodablePayload: [String: AnyEncodable]? { get }
}

public extension Action {
    var encodablePayload: [String: AnyEncodable]? { nil }
}
