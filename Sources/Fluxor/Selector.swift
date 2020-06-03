/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation.NSUUID

/// Something which selects a `Value` from the specified `State`.
public protocol SelectorProtocol {
    /// The input for the `Selector`.
    associatedtype State
    /// The output of the `Selector`,
    associatedtype Value
    /**
     A pure function which takes a `State` and returns a `Value` from it.

     - Parameter state: The `State` to map
     - Returns: The `Value` mapped with the `projector`
     */
    func map(_ state: State) -> Value
}

/**
 A type which takes a `State` and returns a `Value` from it.

 `Selector`s can be based on other `Selector`s making it possible to select a combined `Value`.
 */
public class Selector<State, Value>: SelectorProtocol {
    /// The closue used for the mapping.
    private let map: (State) -> Value
    /// The latest value for a state hash.
    internal private(set) var result: (stateHash: UUID?, value: Value)?

    /**
     Creates a `Selector` from a `keyPath`.

     - Parameter keyPath: The `keyPath` to create the `Selector` from
     */
    public convenience init(keyPath: KeyPath<State, Value>) {
        self.init(map: { $0[keyPath: keyPath] })
    }

    /**
     Creates a `Selector` from a `projector`.

     - Parameter projector: The `projector` to create the `Selector` from
     */
    public convenience init(projector: @escaping (State) -> Value) {
        self.init(map: projector)
    }

    internal init(map: @escaping (State) -> Value) {
        self.map = map
    }

    public func map(_ state: State) -> Value {
        map(state)
    }
}

public class Selector1<State, S1, Value>: Selector<State, Value> where
    S1: SelectorProtocol, S1.State == State {
    public let projector: (S1.Value) -> Value

    /**
     Creates a `Selector` from a `Selector`and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     */
    public init(_ selector1: S1, _ projector: @escaping (S1.Value) -> Value) {
        self.projector = projector
        super.init(map: { projector(selector1.map($0)) })
    }
}

public class Selector2<State, S1, S2, Value>: Selector<State, Value> where
    S1: SelectorProtocol, S1.State == State,
    S2: SelectorProtocol, S2.State == State {
    public let projector: (S1.Value, S2.Value) -> Value
    /**
     Creates a `Selector` from two `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The closure to pass the values from the `Selector`s to
     */
    public init(_ selector1: S1,
                _ selector2: S2,
                _ projector: @escaping (S1.Value, S2.Value) -> Value) {
        self.projector = projector
        super.init(map: { projector(selector1.map($0), selector2.map($0)) })
    }
}

public class Selector3<State, S1, S2, S3, Value>: Selector<State, Value> where
    S1: SelectorProtocol, S1.State == State,
    S2: SelectorProtocol, S2.State == State,
    S3: SelectorProtocol, S3.State == State {
    public let projector: (S1.Value, S2.Value, S3.Value) -> Value

    /**
     Creates a `Selector` from three `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init(_ selector1: S1,
                _ selector2: S2,
                _ selector3: S3,
                _ projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value) {
        self.projector = projector
        super.init(map: { projector(selector1.map($0),
                                    selector2.map($0),
                                    selector3.map($0)) })
    }
}

public class Selector4<State, S1, S2, S3, S4, Value>: Selector<State, Value> where
    S1: SelectorProtocol, S1.State == State,
    S2: SelectorProtocol, S2.State == State,
    S3: SelectorProtocol, S3.State == State,
    S4: SelectorProtocol, S4.State == State {
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value) -> Value

    /**
     Creates a `Selector` from four `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init(_ selector1: S1,
                _ selector2: S2,
                _ selector3: S3,
                _ selector4: S4,
                _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value) {
        self.projector = projector
        super.init(map: { projector(selector1.map($0),
                                    selector2.map($0),
                                    selector3.map($0),
                                    selector4.map($0)) })
    }
}

public class Selector5<State, S1, S2, S3, S4, S5, Value>: Selector<State, Value> where
    S1: SelectorProtocol, S1.State == State,
    S2: SelectorProtocol, S2.State == State,
    S3: SelectorProtocol, S3.State == State,
    S4: SelectorProtocol, S4.State == State,
    S5: SelectorProtocol, S5.State == State {
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value

    /**
     Creates a `Selector` from five `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init(_ selector1: S1,
                _ selector2: S2,
                _ selector3: S3,
                _ selector4: S4,
                _ selector5: S5,
                _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value) {
        self.projector = projector
        super.init(map: { projector(selector1.map($0),
                                    selector2.map($0),
                                    selector3.map($0),
                                    selector4.map($0),
                                    selector5.map($0)) })
    }
}

/// Creator functions.
public extension Selector {
    static func with<S1>(_ selector1: S1,
                         projector: @escaping (S1.Value) -> Value)
        -> Selector1<State, S1, Value> {
        .init(selector1, projector)
    }

    static func with<S1, S2>(_ selector1: S1,
                             _ selector2: S2,
                             projector: @escaping (S1.Value, S2.Value) -> Value)
        -> Selector2<State, S1, S2, Value> {
        .init(selector1, selector2, projector)
    }

    static func with<S1, S2, S3>(_ selector1: S1,
                                 _ selector2: S2,
                                 _ selector3: S3,
                                 projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value)
        -> Selector3<State, S1, S2, S3, Value> {
        .init(selector1, selector2, selector3, projector)
    }

    static func with<S1, S2, S3, S4>(_ selector1: S1,
                                     _ selector2: S2,
                                     _ selector3: S3,
                                     _ selector4: S4,
                                     projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value)
        -> Selector4<State, S1, S2, S3, S4, Value> {
        .init(selector1, selector2, selector3, selector4, projector)
    }

    static func with<S1, S2, S3, S4, S5>(_ selector1: S1,
                                         _ selector2: S2,
                                         _ selector3: S3,
                                         _ selector4: S4,
                                         _ selector5: S5,
                                         projector: @escaping (S1.Value, S2.Value, S3.Value,
                                                               S4.Value, S5.Value) -> Value)
        -> Selector5<State, S1, S2, S3, S4, S5, Value> {
        .init(selector1, selector2, selector3, selector4, selector5, projector)
    }
}

/// Memoization support, where the `Selector` remembers the last result to speed up mapping.
internal extension Selector {
    /**
     Sets the value and the corresponding `stateHash`.

     - Parameter value: The value to save
     - Parameter stateHash: The hash of the state the value was selected from
     */
    func setResult(value: Value, forStateHash stateHash: UUID) {
        result = (stateHash: stateHash, value: value)
    }

    /**
     Selects the `Value` from the `State` based on the subclass's `map` function and saves the result.

     - If a value is already saved and the saved state hash matches the passed, the saved value is returned.
     - If a value is already saved but the saved state hash is nil
        it means that the selector is overriden and it will always return the saved value
     - If a value is already saved but the saved state hash doesn't match the passed
        a new value is selected and saved along with the passed state hash

     - Parameter state: The `State` to select from
     - Parameter stateHash: The hash of the state to select from
     - Returns: The `Value` mapped with the `projector`
     */
    func map(_ state: State, stateHash: UUID) -> Value {
        if let result = result, result.stateHash == nil || result.stateHash == stateHash {
            return result.value
        }
        let value = map(state)
        setResult(value: value, forStateHash: stateHash)
        return value
    }
}

/// Test support.
extension Selector {
    /**
     __Test support:__ Mock the result of the `Selector`. Should only be used by `MockStore` in `FluxorTestSupport`.

     If the selector is mocked the `stateHash` will be nil and `map` will always return the `value`.

     - Parameter value: The value to use as result
     */
    public func mockResult(value: Value) {
        result = (stateHash: nil, value: value)
    }
}
