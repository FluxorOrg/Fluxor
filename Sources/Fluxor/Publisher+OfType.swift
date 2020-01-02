/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine

extension Publisher where Output == Action {
    public func ofType<T>(_ typeToMatch: T.Type) -> AnyPublisher<T, Self.Failure> {
        compactMap { $0 as? T }.eraseToAnyPublisher()
    }
}
