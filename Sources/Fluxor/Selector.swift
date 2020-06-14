/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation.NSUUID

// swiftlint:disable function_parameter_count

public protocol SelectorProtocol {
    /// The input for the `Selector`.
    associatedtype State
    /// The output of the `Selector`,
    associatedtype Value
    /// An unique identifier used for the `Selector`.
    var id: UUID { get }
}

/// Something which selects a `Value` from the specified `State`.
public protocol SelectorWihtoutInputProtocol: SelectorProtocol {
    /**
     A pure function which takes a `State` and returns a `Value` from it.

     - Parameter state: The `State` to map
     - Returns: The `Value` mapped from the `State`
     */
    func map(_ state: State) -> Value
}

public protocol SelectorWithInputProtocol: SelectorProtocol {
    /// The input to the `Selector`.
    associatedtype Input: Hashable

    /**
     A pure function which takes a `State` and returns a `Value` from it.

     - Parameter state: The `State` to map
     - Parameter input: The `Input` to the `Selector`
     - Returns: The `Value` mapped from the `State`
     */
    func map(_ state: State, input: Input) -> Value
}

/**
 A type which takes a `State` and returns a `Value` from it.

 `Selector`s can be based on other `Selector`s making it possible to select a combined `Value`.
 */
public class Selector<State, Value>: SelectorWihtoutInputProtocol {
    /// An unique identifier used for the `Selector`.
    public let id = UUID()
    /// The closue used for the mapping.
    private let _projector: (State) -> Value
    /// The latest value for a state hash.
    internal private(set) var result: (stateHash: UUID, value: Value)?

    /**
     Creates a `Selector` from a `projector` closure.

     - Parameter projector: The `projector` closure to create the `Selector` from
     */
    public init(projector: @escaping (State) -> Value) {
        _projector = projector
    }

    /**
     Creates a `Selector` from a `keyPath`.

     - Parameter keyPath: The `keyPath` to create the `Selector` from
     */
    public convenience init(keyPath: KeyPath<State, Value>) {
        self.init(projector: { state in state[keyPath: keyPath] })
    }

    public func map(_ state: State) -> Value {
        return _projector(state)
    }
}

public class SelectorWithInput<State, Value, Input>: SelectorWithInputProtocol
    where Input: Hashable {
    /// An unique identifier used for the `Selector`.
    public let id = UUID()
    /// The closue used for the mapping.
    private let _projector: (State, Input) -> Value
    /// The latest value for a state hash.
    internal private(set) var resultWithInputHash: (stateHash: UUID, inputHash: Int?, value: Value)?

    /**
     Creates a `Selector` from a `projector` closure.

     - Parameter projector: The `projector` closure to create the `Selector` from
     */
    public init(projector: @escaping (State, Input) -> Value) {
        _projector = projector
    }

    /**
     A pure function which takes a `State` and returns a `Value` from it.

     - Parameter state: The `State` to map
     - Returns: The `Value` mapped from the `State`
     */
    public func map(_ state: State, input: Input) -> Value {
        return _projector(state, input)
    }
}

/// A `Selector` created from a `Selector`s and a `projector` function.
public class Selector1<State, S1, Value>: Selector<State, Value> where
    S1: SelectorWihtoutInputProtocol, S1.State == State {
    /// A pure function which takes the `Value` from the other `Selector` and returns a new `Value`.
    public let projector: (S1.Value) -> Value

    /**
     Creates a `Selector` from a `Selector` and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     */
    public init(_ selector1: S1, _ projector: @escaping (S1.Value) -> Value) {
        self.projector = projector
        super.init { projector(selector1.map($0)) }
    }
}

/// A `Selector` created from a `Selector`s and a `projector` function.
public class Selector1WithInput<State, S1, Value, Input>: SelectorWithInput<State, Value, Input>
    where S1: SelectorWihtoutInputProtocol, S1.State == State, Input: Hashable {
    /// A pure function which takes the `Value` from the other `Selector` and returns a new `Value`.
    public let projector: (S1.Value, Input) -> Value

    /**
     Creates a `Selector` from a `Selector` and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     */
    public init(_ selector1: S1, _ projector: @escaping (S1.Value, Input) -> Value) {
        self.projector = projector
        super.init { projector(selector1.map($0), $1) }
    }
}

/// A `Selector` created from two `Selector`s and a `projector` function.
public class Selector2<State, S1, S2, Value>: Selector<State, Value>
    where S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
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
        super.init(projector: { projector(selector1.map($0), selector2.map($0)) })
    }
}

/// A `Selector` created from two `Selector`s and a `projector` function.
public class SelectorWithInput2<State, S1, S2, Value, Input>: SelectorWithInput<State, Value, Input>
    where Input: Hashable,
    S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
    public let projector: (S1.Value, S2.Value, Input) -> Value

    /**
     Creates a `Selector` from two `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The closure to pass the values from the `Selector`s to
     */
    public init(_ selector1: S1,
                _ selector2: S2,
                _ projector: @escaping (S1.Value, S2.Value, Input) -> Value) {
        self.projector = projector
        super.init(projector: { projector(selector1.map($0), selector2.map($0), $1) })
    }
}

/// A `Selector` created from three `Selector`s and a `projector` function.
public class Selector3<State, S1, S2, S3, Value>: Selector<State, Value>
    where S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
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
        super.init(projector: { state in projector(selector1.map(state),
                                                   selector2.map(state),
                                                   selector3.map(state)) })
    }
}

/// A `Selector` created from three `Selector`s and a `projector` function.
public class SelectorWithInput3<State, S1, S2, S3, Value, Input>: SelectorWithInput<State, Value, Input>
    where Input: Hashable,
    S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
    public let projector: (S1.Value, S2.Value, S3.Value, Input) -> Value

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
                _ projector: @escaping (S1.Value, S2.Value, S3.Value, Input) -> Value) {
        self.projector = projector
        super.init(projector: { projector(selector1.map($0),
                                          selector2.map($0),
                                          selector3.map($0), $1) })
    }
}

//
/// A `Selector` created from four `Selector`s and a `projector` function.
public class Selector4<State, S1, S2, S3, S4, Value>: Selector<State, Value>
    where S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State,
    S4: SelectorWihtoutInputProtocol, S4.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
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
        super.init(projector: { projector(selector1.map($0),
                                          selector2.map($0),
                                          selector3.map($0),
                                          selector4.map($0)) })
    }
}

/// A `Selector` created from four `Selector`s and a `projector` function.
public class SelectorWithInput4<State, S1, S2, S3, S4, Value, Input>: SelectorWithInput<State, Value, Input>
    where Input: Hashable,
    S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State,
    S4: SelectorWihtoutInputProtocol, S4.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value, Input) -> Value

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
                _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, Input) -> Value) {
        self.projector = projector
        super.init(projector: { projector(selector1.map($0),
                                          selector2.map($0),
                                          selector3.map($0),
                                          selector4.map($0), $1) })
    }
}

/// A `Selector` created from five `Selector`s and a `projector` function.
public class Selector5<State, S1, S2, S3, S4, S5, Value>: Selector<State, Value>
    where S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State,
    S4: SelectorWihtoutInputProtocol, S4.State == State,
    S5: SelectorWihtoutInputProtocol, S5.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
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
        super.init(projector: { projector(selector1.map($0),
                                          selector2.map($0),
                                          selector3.map($0),
                                          selector4.map($0),
                                          selector5.map($0)) })
    }
}

/// A `Selector` created from five `Selector`s and a `projector` function.
public class SelectorWithInput5<State, S1, S2, S3, S4, S5, Value, Input>: SelectorWithInput<State, Value, Input>
    where Input: Hashable,
    S1: SelectorWihtoutInputProtocol, S1.State == State,
    S2: SelectorWihtoutInputProtocol, S2.State == State,
    S3: SelectorWihtoutInputProtocol, S3.State == State,
    S4: SelectorWihtoutInputProtocol, S4.State == State,
    S5: SelectorWihtoutInputProtocol, S5.State == State {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value`.
    public let projector: (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value, Input) -> Value

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
                _ projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value, S5.Value, Input) -> Value) {
        self.projector = projector
        super.init(projector: { projector(selector1.map($0),
                                          selector2.map($0),
                                          selector3.map($0),
                                          selector4.map($0),
                                          selector5.map($0), $1) })
    }
}

/// Creator functions.
public extension Selector {
    /**
     Creates a `Selector` from a `Selector` and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     - Returns: A `Selector` from the given `Selector` and the `projector` function
     */
    static func with<S1>(_ selector1: S1,
                         projector: @escaping (S1.Value) -> Value)
        -> Selector1<State, S1, Value> {
        .init(selector1, projector)
    }

    /**
     Creates a `Selector` from a `Selector` and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter projector: The closure to pass the value from the `Selector` to
     - Returns: A `Selector` from the given `Selector` and the `projector` function
     */
    static func with<S1, Input>(_ selector1: S1,
                                projector: @escaping (S1.Value, Input) -> Value)
        -> Selector1WithInput<State, S1, Value, Input> {
        .init(selector1, projector)
    }

    /**
     Creates a `Selector` from two `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The closure to pass the values from the `Selector`s to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2>(_ selector1: S1,
                             _ selector2: S2,
                             projector: @escaping (S1.Value, S2.Value) -> Value)
        -> Selector2<State, S1, S2, Value> {
        .init(selector1, selector2, projector)
    }

    /**
     Creates a `Selector` from two `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The closure to pass the values from the `Selector`s to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, Input>(_ selector1: S1,
                                    _ selector2: S2,
                                    projector: @escaping (S1.Value, S2.Value, Input) -> Value)
        -> SelectorWithInput2<State, S1, S2, Value, Input> {
        .init(selector1, selector2, projector)
    }

    /**
     Creates a `Selector` from three `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, S3>(_ selector1: S1,
                                 _ selector2: S2,
                                 _ selector3: S3,
                                 projector: @escaping (S1.Value, S2.Value, S3.Value) -> Value)
        -> Selector3<State, S1, S2, S3, Value> {
        .init(selector1, selector2, selector3, projector)
    }

    /**
     Creates a `Selector` from three `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, S3, Input>(_ selector1: S1,
                                        _ selector2: S2,
                                        _ selector3: S3,
                                        projector: @escaping (S1.Value, S2.Value, S3.Value, Input) -> Value)
        -> SelectorWithInput3<State, S1, S2, S3, Value, Input> {
        .init(selector1, selector2, selector3, projector)
    }

    /**
     Creates a `Selector` from four `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, S3, S4>(_ selector1: S1,
                                     _ selector2: S2,
                                     _ selector3: S3,
                                     _ selector4: S4,
                                     projector: @escaping (S1.Value, S2.Value, S3.Value, S4.Value) -> Value)
        -> Selector4<State, S1, S2, S3, S4, Value> {
        .init(selector1, selector2, selector3, selector4, projector)
    }

    /**
     Creates a `Selector` from four `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, S3, S4, Input>(_ selector1: S1,
                                            _ selector2: S2,
                                            _ selector3: S3,
                                            _ selector4: S4,
                                            projector: @escaping (S1.Value, S2.Value, S3.Value,
                                                                  S4.Value, Input) -> Value)
        -> SelectorWithInput4<State, S1, S2, S3, S4, Value, Input> {
        .init(selector1, selector2, selector3, selector4, projector)
    }

    /**
     Creates a `Selector` from five `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
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

    /**
     Creates a `Selector` from five `Selector`s and a `projector` function.

     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The closure to pass the values from the `Selectors` to
     - Returns: A `Selector` from the given `Selector`s and the `projector` function
     */
    static func with<S1, S2, S3, S4, S5, Input>(_ selector1: S1,
                                                _ selector2: S2,
                                                _ selector3: S3,
                                                _ selector4: S4,
                                                _ selector5: S5,
                                                projector: @escaping (S1.Value, S2.Value, S3.Value,
                                                                      S4.Value, S5.Value, Input) -> Value)
        -> SelectorWithInput5<State, S1, S2, S3, S4, S5, Value, Input> {
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
     - If a value is already saved but the saved state hash doesn't match the passed
        a new value is selected and saved along with the passed state hash

     - Parameter state: The `State` to select from
     - Parameter stateHash: The hash of the `State` to select from
     - Returns: The `Value` mapped with the `projector`
     */
    func map(_ state: State, stateHash: UUID) -> Value {
        if let result = result, result.stateHash == stateHash {
            return result.value
        }
        let value = map(state)
        setResult(value: value, forStateHash: stateHash)
        return value
    }
}

internal extension SelectorWithInput {
    /**
     Sets the value and the corresponding `stateHash`.

     - Parameter value: The value to save
     - Parameter stateHash: The hash of the state the value was selected from
     */
    func setResult(value: Value, forStateHash stateHash: UUID, inputHash: Int) {
        resultWithInputHash = (stateHash: stateHash, inputHash: inputHash, value: value)
    }

    /**
     Selects the `Value` from the `State` based on the subclass's `map` function and saves the result.

     - If a value is already saved and the saved state hash matches the passed, the saved value is returned.
     - If a value is already saved but the saved state hash doesn't match the passed
        a new value is selected and saved along with the passed state hash

     - Parameter state: The `State` to select from
     - Parameter stateHash: The hash of the `State` to select from
     - Returns: The `Value` mapped with the `projector`
     */
    func map(_ state: State, stateHash: UUID, input: Input) -> Value {
        if let result = resultWithInputHash, result.stateHash == stateHash, result.inputHash == input.hashValue {
            return result.value
        }
        let value = map(state, input: input)
        setResult(value: value, forStateHash: stateHash, inputHash: input.hashValue)
        return value
    }
}
