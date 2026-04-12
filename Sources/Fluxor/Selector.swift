/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// Something which selects a `Value` from the specified `State`.
public final class Selector<State, Value>: @unchecked Sendable {
    public let id = UUID()
    private let projector: (State) -> Value

    public init(_ keyPath: KeyPath<State, Value>) {
        projector = { $0[keyPath: keyPath] }
    }

    public init(projector: @escaping (State) -> Value) {
        self.projector = projector
    }

    public func map(_ state: State) -> Value {
        projector(state)
    }
}

public extension Selector {
    static func combine<S1: Equatable>(
        _ selector1: Selector<State, S1>,
        projector: @escaping (S1) -> Value
    ) -> Selector<State, Value> {
        var cache: (S1, Value)?
        return .init(projector: { state in
            let value1 = selector1.map(state)
            if let cache, cache.0 == value1 {
                return cache.1
            }

            let projectedValue = projector(value1)
            cache = (value1, projectedValue)
            return projectedValue
        })
    }

    static func combine<S1: Equatable, S2: Equatable>(
        _ selector1: Selector<State, S1>,
        _ selector2: Selector<State, S2>,
        projector: @escaping (S1, S2) -> Value
    ) -> Selector<State, Value> {
        var cache: ((S1, S2), Value)?
        return .init(projector: { state in
            let value1 = selector1.map(state)
            let value2 = selector2.map(state)
            if let cache, cache.0 == (value1, value2) {
                return cache.1
            }

            let projectedValue = projector(value1, value2)
            cache = ((value1, value2), projectedValue)
            return projectedValue
        })
    }

    static func combine<S1: Equatable, S2: Equatable, S3: Equatable>(
        _ selector1: Selector<State, S1>,
        _ selector2: Selector<State, S2>,
        _ selector3: Selector<State, S3>,
        projector: @escaping (S1, S2, S3) -> Value
    ) -> Selector<State, Value> {
        var cache: ((S1, S2, S3), Value)?
        return .init(projector: { state in
            let value1 = selector1.map(state)
            let value2 = selector2.map(state)
            let value3 = selector3.map(state)
            if let cache, cache.0 == (value1, value2, value3) {
                return cache.1
            }

            let projectedValue = projector(value1, value2, value3)
            cache = ((value1, value2, value3), projectedValue)
            return projectedValue
        })
    }

    static func combine<S1: Equatable, S2: Equatable, S3: Equatable, S4: Equatable>(
        _ selector1: Selector<State, S1>,
        _ selector2: Selector<State, S2>,
        _ selector3: Selector<State, S3>,
        _ selector4: Selector<State, S4>,
        projector: @escaping (S1, S2, S3, S4) -> Value
    ) -> Selector<State, Value> {
        var cache: ((S1, S2, S3, S4), Value)?
        return .init(projector: { state in
            let value1 = selector1.map(state)
            let value2 = selector2.map(state)
            let value3 = selector3.map(state)
            let value4 = selector4.map(state)
            if let cache, cache.0 == (value1, value2, value3, value4) {
                return cache.1
            }

            let projectedValue = projector(value1, value2, value3, value4)
            cache = ((value1, value2, value3, value4), projectedValue)
            return projectedValue
        })
    }

    static func combine<S1: Equatable, S2: Equatable, S3: Equatable, S4: Equatable, S5: Equatable>(
        _ selector1: Selector<State, S1>,
        _ selector2: Selector<State, S2>,
        _ selector3: Selector<State, S3>,
        _ selector4: Selector<State, S4>,
        _ selector5: Selector<State, S5>,
        projector: @escaping (S1, S2, S3, S4, S5) -> Value
    ) -> Selector<State, Value> {
        var cache: ((S1, S2, S3, S4, S5), Value)?
        return .init(projector: { state in
            let value1 = selector1.map(state)
            let value2 = selector2.map(state)
            let value3 = selector3.map(state)
            let value4 = selector4.map(state)
            let value5 = selector5.map(state)
            if let cache, cache.0 == (value1, value2, value3, value4, value5) {
                return cache.1
            }

            let projectedValue = projector(value1, value2, value3, value4, value5)
            cache = ((value1, value2, value3, value4, value5), projectedValue)
            return projectedValue
        })
    }
}
