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
public class RootSelector<State, Value>: MemoizedSelector<State, Value> {
    internal let keyPath: KeyPath<State, Value>

    public init(keyPath: KeyPath<State, Value>) {
        self.keyPath = keyPath
    }

    public override func map(_ state: State) -> Value {
        return state[keyPath: keyPath]
    }
}

/// A `Selector` based on a one other `Selector`.
public class Selector1<State, S1, Value>: MemoizedSelector<State, Value> where
    S1: Selector, S1.State == State {
    internal let selector1: S1
    public let projector: (S1.Value) -> Value

    public init(selector1: S1, projector: @escaping (S1.Value) -> Value) {
        self.selector1 = selector1
        self.projector = projector
    }

    public override func map(_ state: State) -> Value {
        return projector(selector1.map(state))
    }
}

/// A `Selector` based on a two other `Selector`s.
public class Selector2<State, S1, S2, Value>: MemoizedSelector<State, Value> where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State {
    internal let selector1: S1
    internal let selector2: S2
    public let projector: (S1.Value, S2.Value) -> Value

    public init(selector1: S1, selector2: S2, projector: @escaping (S1.Value, S2.Value) -> Value) {
        self.selector1 = selector1
        self.selector2 = selector2
        self.projector = projector
    }

    public override func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state))
    }
}

/// A `Selector` based on a three other `Selector`s.
public class Selector3<State, S1, S2, S3, Value>: MemoizedSelector<State, Value> where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State {
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    public let projector: (S1.Value, S2.Value, S3.Value) -> Value

    public init(selector1: S1, selector2: S2, selector3: S3,
                projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value) {
        self.selector1 = selector1
        self.selector2 = selector2
        self.selector3 = selector3
        self.projector = projector
    }

    public override func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state))
    }
}

/// A `Selector` based on a four  other `Selector`s.
public class Selector4<State, S1, S2, S3, S4, Value>: MemoizedSelector<State, Value> where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State,
    S4: Selector, S4.State == State {
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    internal let selector4: S4
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value) -> Value

    public init(selector1: S1, selector2: S2, selector3: S3, selector4: S4,
                projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value) {
        self.selector1 = selector1
        self.selector2 = selector2
        self.selector3 = selector3
        self.selector4 = selector4
        self.projector = projector
    }

    public override func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state), selector4.map(state))
    }
}

/// A `Selector` based on a five other `Selector`s.
public class Selector5<State, S1, S2, S3, S4, S5, Value>: MemoizedSelector<State, Value> where
    S1: Selector, S1.State == State,
    S2: Selector, S2.State == State,
    S3: Selector, S3.State == State,
    S4: Selector, S4.State == State,
    S5: Selector, S5.State == State {
    internal let selector1: S1
    internal let selector2: S2
    internal let selector3: S3
    internal let selector4: S4
    internal let selector5: S5
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value

    public init(selector1: S1, selector2: S2, selector3: S3, selector4: S4, selector5: S5,
                projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value) {
        self.selector1 = selector1
        self.selector2 = selector2
        self.selector3 = selector3
        self.selector4 = selector4
        self.selector5 = selector5
        self.projector = projector
    }

    public override func map(_ state: State) -> Value {
        return projector(selector1.map(state), selector2.map(state), selector3.map(state), selector4.map(state), selector5.map(state))
    }
}

/// A `Selector` which remembers the last result to speed up mapping
public class MemoizedSelector<State, Value>: Selector {
    /// The latest value for a state hash.
    internal var result: (stateHash: UUID?, value: Value)?

    /**
     Sets the value and the corresponding `stateHash`.

     If the selector is overriden in a `MockStore` the `stateHash` will be nil and the `map` will always return the `value`.

     - Parameter value: The value to save
     - Parameter stateHash: The hash of the state the value was selected from
     */
    internal func setResult(value: Value, forStateHash stateHash: UUID? = nil) {
        result = (stateHash: stateHash, value: value)
    }

    /**
     Selects the `Value` from the `State` based on the subclass's `map` function and saves the result.

     - If a value is already saved and the saved state hash matches the passed, the saved value is returned.
     - If a value is already saved but the saved state hash is nil it means that the selector is overriden and it will always return the saved value
     - If a value is already saved but the saved state hash doesn't match the passed a new value is selected and saved along with the passed state hash

     - Parameter state: The `State` to select from
     - Parameter stateHash: The hash of the state to select from
     */
    internal func map(_ state: State, stateHash: UUID) -> Value {
        if let result = result, result.stateHash == nil || result.stateHash == stateHash {
            return result.value
        }
        let value = map(state)
        setResult(value: value, forStateHash: stateHash)
        return value
    }

    /**
     The function called when selecting from a `Store`. This should be overriden in a subclass with logic for how to select the `Value` from the `State`.

     - Parameter state: The `State` to select from
     */
    public func map(_ state: State) -> Value {
        fatalError("Must be implemented in subclass")
    }
}
