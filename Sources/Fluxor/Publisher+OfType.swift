//
//  Publisher+OfType.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine

extension Publisher where Output == Action {
    public func ofType<T>(_ typeToMatch: T.Type) -> Publishers.Filter<Self> {
        filter { type(of: $0) == typeToMatch }
    }
}
