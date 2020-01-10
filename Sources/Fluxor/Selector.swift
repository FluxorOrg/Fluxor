/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A pure function which takes a `State` and returns a slice of it.
public protocol Selector {
    associatedtype State
    associatedtype Value
    func map(_ state: State) -> Value
}

// MARK: - Functions

public func createRootSelector<State, Value>(
    projector: @escaping (State) -> Value
) -> RootSelector<State, Value> {
    return RootSelector(projector: projector)
}

public func createSelector<State, S1, R1, Value>(
    selector1: S1, projector: @escaping (R1) -> Value
) -> Selector1<State, S1, R1, Value> {
    return Selector1(selector1: selector1, projector: projector)
}

public func createSelector<State, S1, S2, R1, R2, Value>(
    selector1: S1, selector2: S2, projector: @escaping (R1, R2) -> Value
) -> Selector2<State, S1, S2, R1, R2, Value> {
    return Selector2(selector1: selector1, selector2: selector2, projector: projector)
}

public func createSelector<State, S1, S2, S3, R1, R2, R3, Value>(
    selector1: S1, selector2: S2, selector3: S3, projector: @escaping (R1, R2, R3) -> Value
) -> Selector3<State, S1, S2, S3, R1, R2, R3, Value> {
    return Selector3(selector1: selector1, selector2: selector2, selector3: selector3, projector: projector)
}

// MARK: - Types

public struct RootSelector<State, Value>: Selector {
    internal let projector: (State) -> Value

    public func map(_ state: State) -> Value {
        return projector(state)
    }
}

public struct Selector1<State, S1, R1, Value>: Selector where
    S1: Selector, S1.State == State, S1.Value == R1 {
    internal let selector1: S1
    internal let projector: (R1) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state))
    }
}

public struct Selector2<State, S1, S2, R1, R2, Value>: Selector where
    S1: Selector, S1.State == State, S1.Value == R1,
    S2: Selector, S2.State == State, S2.Value == R2 {
    internal let selector1: S1
    internal let selector2: S2
    internal let projector: (R1, R2) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state))
    }
}

public struct Selector3<State, S1, S2, S3, R1, R2, R3, Value>: Selector where
    S1: Selector, S1.State == State, S1.Value == R1,
    S2: Selector, S2.State == State, S2.Value == R2,
    S3: Selector, S3.State == State, S3.Value == R3 {
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    internal let projector: (R1, R2, R3) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state))
    }
}
