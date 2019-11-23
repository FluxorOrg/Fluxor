//
//  Publisher+OfType.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine

extension Publisher where Output == Action {
    public func ofType<T>(_ typeToMatch: T.Type) -> AnyPublisher<T, Self.Failure> {
        compactMap { $0 as? T }.eraseToAnyPublisher()
    }
}
