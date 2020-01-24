/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A pure function which takes a `State` and returns a `Value` based on it.
public protocol Selector {
    associatedtype State
    associatedtype Value
    var id: UUID { get }
    /// The function called when selecting from a `Store`.
    func map(_ state: State) -> Value
}

/**
 Creates a `RootSelector` from a `keyPath`.

 - Parameter keyPath: The `keyPath` to create `RootSelector` from
 */
public func createRootSelector<State, Value>(
    keyPath: KeyPath<State, Value>
) -> RootSelector<State, Value> {
    return RootSelector(keyPath: keyPath)
}

/**
 Creates a `Selector1` from a `Selector`and a `projector` function.

 - Parameter selector1: The first `Selector`
 - Parameter projector: The closure to pass the value from the `Selector` to
 */
public func createSelector<State, S1, Value>(
    _ selector1: S1, _ projector: @escaping (S1.Value) -> Value
) -> Selector1<State, S1, Value> {
    return Selector1(selector1: selector1, projector: projector)
}

/**
 Creates a `Selector2` from two `Selector`s and a `projector` function.

 - Parameter selector1: The first `Selector`
 - Parameter selector2: The second `Selector`
 - Parameter projector: The closure to pass the values from the `Selectors` to
 */
public func createSelector<State, S1, S2, Value>(
    _ selector1: S1, _ selector2: S2, _ projector: @escaping (S1.Value, S2.Value) -> Value
) -> Selector2<State, S1, S2, Value> {
    return Selector2(selector1: selector1, selector2: selector2, projector: projector)
}

/**
 Creates a `Selector3` from three `Selector`s and a `projector` function.

 - Parameter selector1: The first `Selector`
 - Parameter selector2: The second `Selector`
 - Parameter selector3: The third `Selector`
 - Parameter projector: The closure to pass the values from the `Selectors` to
 */
public func createSelector<State, S1, S2, S3, Value>(
    _ selector1: S1, _ selector2: S2, _ selector3: S3, _ projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value
) -> Selector3<State, S1, S2, S3, Value> {
    return Selector3(selector1: selector1, selector2: selector2, selector3: selector3, projector: projector)
}

/**
 Creates a `Selector4` from four `Selector`s and a `projector` function.

 - Parameter selector1: The first `Selector`
 - Parameter selector2: The second `Selector`
 - Parameter selector3: The third `Selector`
 - Parameter selector4: The fourth `Selector`
 - Parameter projector: The closure to pass the values from the `Selectors` to
 */
public func createSelector<State, S1, S2, S3, S4, Value>(
    _ selector1: S1, _ selector2: S2, _ selector3: S3, _ selector4: S4, _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value
) -> Selector4<State, S1, S2, S3, S4, Value> {
    return Selector4(selector1: selector1, selector2: selector2, selector3: selector3, selector4: selector4, projector: projector)
}

/**
 Creates a `Selector5` from five `Selector`s and a `projector` function.

 - Parameter selector1: The first `Selector`
 - Parameter selector2: The second `Selector`
 - Parameter selector3: The third `Selector`
 - Parameter selector4: The fourth `Selector`
 - Parameter selector5: The fifth `Selector`
 - Parameter projector: The closure to pass the values from the `Selectors` to
 */
public func createSelector<State, S1, S2, S3, S4, S5, Value>(
    _ selector1: S1, _ selector2: S2, _ selector3: S3, _ selector4: S4, _ selector5: S5, _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value
) -> Selector5<State, S1, S2, S3, S4, S5, Value> {
    return Selector5(selector1: selector1, selector2: selector2, selector3: selector3, selector4: selector4, selector5: selector5, projector: projector)
}

/**
 A `Selector` to get one of the root states in the `State` with a `KeyPath`.

 Use it as a starting point in one of the other `Selector`s.
 */
public struct RootSelector<State, Value>: Selector {
    public let id = UUID()
    internal let keyPath: KeyPath<State, Value>

    public func map(_ state: State) -> Value {
        return state[keyPath: keyPath]
    }
}

/// A `Selector` based on a one other `Selector`.
public struct Selector1<State, S1, Value>: Selector where
    S1: Selector, S1.State == State {
    public let id = UUID()
    internal let selector1: S1
    public let projector: (S1.Value) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state))
    }
}

/// A `Selector` based on a two other `Selector`s.
public struct Selector2<State, S1, S2, Value>: Selector where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State {
    public let id = UUID()
    internal let selector1: S1
    internal let selector2: S2
    public let projector: (S1.Value, S2.Value) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state))
    }
}

/// A `Selector` based on a three other `Selector`s.
public struct Selector3<State, S1, S2, S3, Value>: Selector where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State {
    public let id = UUID()
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    public let projector: (S1.Value, S2.Value, S3.Value) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state))
    }
}

/// A `Selector` based on a four  other `Selector`s.
public struct Selector4<State, S1, S2, S3, S4, Value>: Selector where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State,
    S4: Selector, S4.State == State {
    public let id = UUID()
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    internal let selector4: S4
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state), selector4.map(state))
    }
}

/// A `Selector` based on a five other `Selector`s.
public struct Selector5<State, S1, S2, S3, S4, S5, Value>: Selector where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State,
    S4: Selector, S4.State == State,
    S5: Selector, S5.State == State {
    public let id = UUID()
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    internal let selector4: S4
    internal let selector5: S5
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value

    public func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state), selector4.map(state), selector5.map(state))
    }
}
