/**
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
    /// A pure function which takes a `State` and returns a `Value` from it.
    func map(_ state: State) -> Value
}

/**
 A type which takes a `State` and returns a `Value` from it.

 `Selector`s can be based on other `Selector`s making it possible to select a combined `Value`.
 */
public class Selector<State, Value>: SelectorProtocol {
    /// The closue used for the mapping.
    internal let map: (State) -> Value
    /// The latest value for a state hash.
    internal private(set) var result: (stateHash: UUID?, value: Value)?

    /**
     Creates a `Selector` from a `keyPath`.

     - Parameter keyPath: The `keyPath` to create the `Selector` from
     */
    public init(keyPath: KeyPath<State, Value>) {
        map = { $0[keyPath: keyPath] }
    }

    /**
     Creates a `Selector` from a `projector`.

     - Parameter projector: The `projector` to create the `Selector` from
     */
    public init(projector: @escaping (State) -> Value) {
        map = projector
    }

    /**
     Creates a `Selector` from a `Selector`and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     */

    public init<S1>(_ selector1: S1,
                    _ projector: @escaping (S1.Value) -> Value)
        where S1: SelectorProtocol, S1.State == State {
        map = { projector(selector1.map($0)) }
    }

    /**
     Creates a `Selector` from two `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The closure to pass the values from the `Selector`s to
     */
    public init<S1, S2>(_ selector1: S1,
                        _ selector2: S2,
                        _ projector: @escaping (S1.Value, S2.Value) -> Value)
        where S1: SelectorProtocol, S1.State == State,
        S2: SelectorProtocol, S2.State == State {
        map = { projector(selector1.map($0),
                          selector2.map($0)) }
    }

    /**
     Creates a `Selector` from three `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init<S1, S2, S3>(_ selector1: S1,
                            _ selector2: S2,
                            _ selector3: S3,
                            _ projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value)
        where S1: SelectorProtocol, S1.State == State,
        S2: SelectorProtocol, S2.State == State,
        S3: SelectorProtocol, S3.State == State {
        map = { projector(selector1.map($0),
                          selector2.map($0),
                          selector3.map($0)) }
    }

    /**
     Creates a `Selector` from four `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init<S1, S2, S3, S4>(_ selector1: S1,
                                _ selector2: S2,
                                _ selector3: S3,
                                _ selector4: S4,
                                _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value)
        where S1: SelectorProtocol, S1.State == State,
        S2: SelectorProtocol, S2.State == State,
        S3: SelectorProtocol, S3.State == State,
        S4: SelectorProtocol, S4.State == State {
        map = { projector(selector1.map($0),
                          selector2.map($0),
                          selector3.map($0),
                          selector4.map($0)) }
    }

    /**
     Creates a `Selector` from five `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     */
    public init<S1, S2, S3, S4, S5>(_ selector1: S1,
                                    _ selector2: S2,
                                    _ selector3: S3,
                                    _ selector4: S4,
                                    _ selector5: S5,
                                    _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value) -> Value)
        where S1: SelectorProtocol, S1.State == State,
        S2: SelectorProtocol, S2.State == State,
        S3: SelectorProtocol, S3.State == State,
        S4: SelectorProtocol, S4.State == State,
        S5: SelectorProtocol, S5.State == State {
        map = { projector(selector1.map($0),
                          selector2.map($0),
                          selector3.map($0),
                          selector4.map($0),
                          selector5.map($0)) }
    }

    public func map(_ state: State) -> Value {
        return map(state)
    }
}

/// Memoization support, where the `Selector` remembers the last result to speed up mapping.
extension Selector {
    /**
     Sets the value and the corresponding `stateHash`.

     - Parameter value: The value to save
     - Parameter stateHash: The hash of the state the value was selected from
     */
    internal func setResult(value: Value, forStateHash stateHash: UUID) {
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
     */
    internal func map(_ state: State, stateHash: UUID) -> Value {
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
