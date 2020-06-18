/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation.NSUUID

// swiftlint:disable function_parameter_count

/// Something which selects a `Value` from the specified `State`.
public protocol SelectorProtocol {
    /// The data for the `Selector` to map.
    associatedtype State
    /// The output of the `Selector`.
    associatedtype Value
    /// The input of the `Selector`.
    associatedtype Input
    /// An unique identifier.
    var id: String { get }
    /**
     A pure function which takes a `State` and an `Input` and returns a `Value`.

     - Parameter state: The `State` to map
     - Parameter input: The `Input` for the mapping
     - Returns: The `Value` mapped from the `State`
     */
    func map(_ state: State, input: Input) -> Value
}

/// Something which selects a `Value` from the specified `State`.
public class Selector<State, Value, Input>: SelectorProtocol {
    public let id: String
    /// The latest value for a state hash and input.
    internal private(set) var result: (stateHash: UUID, input: Input?, value: Value)?
    /// The closue used for the mapping.
    private let _projector: (State, Input) -> Value

    /**
     Creates a `Selector` from a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter state: The `State` to map
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString, projector: @escaping (_ state: State, _ input: Input) -> Value) {
        self.id = id
        _projector = projector
    }

    public func map(_ state: State, input: Input) -> Value {
        return _projector(state, input)
    }
}

public extension Selector where Input == Void {
    /**
     Creates a `Selector` from a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter state: The `State` to map
     */
    convenience init(id: String = UUID().uuidString, projector: @escaping (_ state: State) -> Value) {
        self.init(id: id, projector: { state, _ in projector(state) })
    }

    /**
     Creates a `Selector` from a `keyPath`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter keyPath: The `keyPath` to create the `Selector` from
     */
    convenience init(id: String = UUID().uuidString, keyPath: KeyPath<State, Value>) {
        self.init(id: id, projector: { state in state[keyPath: keyPath] })
    }

    /**
     A pure function which takes a `State` and returns a `Value`.

     - Parameter state: The `State` to map
     - Returns: The `Value` mapped from the `State`
     */
    func map(_ state: State) -> Value {
        return map(state, input: Void())
    }
}

/// A `Selector` created from a `Selector`s and a `projector` closure.
public class Selector1<State, S1Value, Value, Input>: Selector<State, Value, Input> {
    /// A pure function which takes the `Value` from the other `Selector` and returns a new `Value` based on the `Input`.
    public let projector: (S1Value, Input) -> Value

    /**
     Creates a `Selector` from a `Selector` and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString,
                _ selector1: Selector<State, S1Value, Void>,
                _ projector: @escaping (_ s1Value: S1Value, _ input: Input) -> Value) {
        self.projector = projector
        super.init(id: id) { projector(selector1.map($0), $1) }
    }
}

public extension Selector1 where Input == Void {
    /**
     Creates a `Selector` from a `Selector` and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     */
    convenience init(id: String = UUID().uuidString,
                     _ selector1: Selector<State, S1Value, Void>,
                     _ projector: @escaping (_ s1Value: S1Value) -> Value) {
        self.init(id: id, selector1) { state, _ in projector(state) }
    }
}

public class Selector2<State, S1Value, S2Value, Value, Input>: Selector<State, Value, Input> {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value` based on the `Input`.
    public let projector: (S1Value, S2Value, Input) -> Value

    /**
     Creates a `Selector` from two `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString,
                _ selector1: Selector<State, S1Value, Void>,
                _ selector2: Selector<State, S2Value, Void>,
                _ projector: @escaping (_ s1Value: S1Value,
                                        _ s2Value: S2Value,
                                        _ input: Input) -> Value) {
        self.projector = projector
        super.init(id: id) { projector(selector1.map($0), selector2.map($0), $1) }
    }
}

public extension Selector2 where Input == Void {
    /**
     Creates a `Selector` from two `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     */
    convenience init(id: String = UUID().uuidString,
                     _ selector1: Selector<State, S1Value, Void>,
                     _ selector2: Selector<State, S2Value, Void>,
                     _ projector: @escaping (_ s1Value: S1Value,
                                             _ s2Value: S2Value) -> Value) {
        self.init(id: id, selector1, selector2) { value1, value2, _ in projector(value1, value2) }
    }
}

public class Selector3<State, S1Value, S2Value, S3Value, Value, Input>: Selector<State, Value, Input> {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value` based on the `Input`.
    public let projector: (S1Value, S2Value, S3Value, Input) -> Value

    /**
     Creates a `Selector` from three `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString,
                _ selector1: Selector<State, S1Value, Void>,
                _ selector2: Selector<State, S2Value, Void>,
                _ selector3: Selector<State, S3Value, Void>,
                _ projector: @escaping (_ s1Value: S1Value,
                                        _ s2Value: S2Value,
                                        _ s3Value: S3Value,
                                        _ input: Input) -> Value) {
        self.projector = projector
        super.init(id: id) { projector(selector1.map($0), selector2.map($0), selector3.map($0), $1) }
    }
}

public extension Selector3 where Input == Void {
    /**
     Creates a `Selector` from three `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     */
    convenience init(id: String = UUID().uuidString,
                     _ selector1: Selector<State, S1Value, Void>,
                     _ selector2: Selector<State, S2Value, Void>,
                     _ selector3: Selector<State, S3Value, Void>,
                     _ projector: @escaping (_ s1Value: S1Value,
                                             _ s2Value: S2Value,
                                             _ s3Value: S3Value) -> Value) {
        self.init(id: id, selector1, selector2, selector3) { value1, value2, value3, _ in
            projector(value1, value2, value3)
        }
    }
}

public class Selector4<State, S1Value, S2Value, S3Value, S4Value, Value, Input>: Selector<State, Value, Input> {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value` based on the `Input`.
    public let projector: (S1Value, S2Value, S3Value, S4Value, Input) -> Value

    /**
     Creates a `Selector` from four `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString,
                _ selector1: Selector<State, S1Value, Void>,
                _ selector2: Selector<State, S2Value, Void>,
                _ selector3: Selector<State, S3Value, Void>,
                _ selector4: Selector<State, S4Value, Void>,
                _ projector: @escaping (_ s1Value: S1Value,
                                        _ s2Value: S2Value,
                                        _ s3Value: S3Value,
                                        _ s4Value: S4Value,
                                        _ input: Input) -> Value) {
        self.projector = projector
        super.init(id: id) { projector(selector1.map($0), selector2.map($0), selector3.map($0), selector4.map($0), $1) }
    }
}

public extension Selector4 where Input == Void {
    /**
     Creates a `Selector` from four `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     */
    convenience init(id: String = UUID().uuidString,
                     _ selector1: Selector<State, S1Value, Void>,
                     _ selector2: Selector<State, S2Value, Void>,
                     _ selector3: Selector<State, S3Value, Void>,
                     _ selector4: Selector<State, S4Value, Void>,
                     _ projector: @escaping (_ s1Value: S1Value,
                                             _ s2Value: S2Value,
                                             _ s3Value: S3Value,
                                             _ s4Value: S4Value) -> Value) {
        self.init(id: id, selector1, selector2, selector3, selector4) { value1, value2, value3, value4, _ in
            projector(value1, value2, value3, value4)
        }
    }
}

public class Selector5<State, S1Value, S2Value, S3Value, S4Value, S5Value, Value, Input>:
    Selector<State, Value, Input> {
    /// A pure function which takes the `Value`s from the other `Selector`s and returns a new `Value` based on the `Input`.
    public let projector: (S1Value, S2Value, S3Value, S4Value, S5Value, Input) -> Value

    /**
     Creates a `Selector` from five `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter s5Value: The `Value` from the fifth `Selector`
     - Parameter input: The `Input` for the mapping
     */
    public init(id: String = UUID().uuidString,
                _ selector1: Selector<State, S1Value, Void>,
                _ selector2: Selector<State, S2Value, Void>,
                _ selector3: Selector<State, S3Value, Void>,
                _ selector4: Selector<State, S4Value, Void>,
                _ selector5: Selector<State, S5Value, Void>,
                _ projector: @escaping (_ s1Value: S1Value,
                                        _ s2Value: S2Value,
                                        _ s3Value: S3Value,
                                        _ s4Value: S4Value,
                                        _ s5Value: S5Value,
                                        _ input: Input) -> Value) {
        self.projector = projector
        super.init(id: id) { projector(selector1.map($0),
                                       selector2.map($0),
                                       selector3.map($0),
                                       selector4.map($0),
                                       selector5.map($0), $1) }
    }
}

public extension Selector5 where Input == Void {
    /**
     Creates a `Selector` from five `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter s5Value: The `Value` from the fifth `Selector`
     */
    convenience init(id: String = UUID().uuidString,
                     _ selector1: Selector<State, S1Value, Void>,
                     _ selector2: Selector<State, S2Value, Void>,
                     _ selector3: Selector<State, S3Value, Void>,
                     _ selector4: Selector<State, S4Value, Void>,
                     _ selector5: Selector<State, S5Value, Void>,
                     _ projector: @escaping (_ s1Value: S1Value,
                                             _ s2Value: S2Value,
                                             _ s3Value: S3Value,
                                             _ s4Value: S4Value,
                                             _ s5Value: S5Value) -> Value) {
        self.init(id: id, selector1, selector2, selector3, selector4, selector5) {
            value1, value2, value3, value4, value5, _ in
            projector(value1, value2, value3, value4, value5)
        }
    }
}

public extension Selector where Input == Void {
    static func with(id: String = UUID().uuidString,
                     _ projector: @escaping (State) -> Value)
        -> Selector<State, Value, Void> {
        return .init(projector: projector)
    }

    /**
     Creates a `Selector` from a `Selector` and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Returns: A `Selector` from the given `Selector` and the `projector` closure
     */
    static func with<S1Value>(id: String = UUID().uuidString,
                              _ selector1: Selector<State, S1Value, Void>,
                              _ projector: @escaping (_ s1Value: S1Value) -> Value)
        -> Selector1<State, S1Value, Value, Void> {
        return .init(id: id, selector1, projector)
    }

    /**
     Creates a `Selector` from two `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Returns: A `Selector` from the given `Selector`s and the `projector` closure
     */
    static func with<S1Value, S2Value>(id: String = UUID().uuidString,
                                       _ selector1: Selector<State, S1Value, Void>,
                                       _ selector2: Selector<State, S2Value, Void>,
                                       _ projector: @escaping (_ s1Value: S1Value,
                                                               _ s2Value: S2Value) -> Value)
        -> Selector2<State, S1Value, S2Value, Value, Void> {
        .init(id: id, selector1, selector2, projector)
    }

    /**
     Creates a `Selector` from three `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     */
    static func with<S1Value, S2Value, S3Value>(id: String = UUID().uuidString,
                                                _ selector1: Selector<State, S1Value, Void>,
                                                _ selector2: Selector<State, S2Value, Void>,
                                                _ selector3: Selector<State, S3Value, Void>,
                                                _ projector: @escaping (_ s1Value: S1Value,
                                                                        _ s2Value: S2Value,
                                                                        _ s3Value: S3Value) -> Value)
        -> Selector3<State, S1Value, S2Value, S3Value, Value, Void> {
        .init(id: id, selector1, selector2, selector3, projector)
    }

    /**
     Creates a `Selector` from four `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     */
    static func with<S1Value, S2Value, S3Value, S4Value>(id: String = UUID().uuidString,
                                                         _ selector1: Selector<State, S1Value, Void>,
                                                         _ selector2: Selector<State, S2Value, Void>,
                                                         _ selector3: Selector<State, S3Value, Void>,
                                                         _ selector4: Selector<State, S4Value, Void>,
                                                         _ projector: @escaping (_ s1Value: S1Value,
                                                                                 _ s2Value: S2Value,
                                                                                 _ s3Value: S3Value,
                                                                                 _ s4Value: S4Value) -> Value)
        -> Selector4<State, S1Value, S2Value, S3Value, S4Value, Value, Void> {
        .init(id: id, selector1, selector2, selector3, selector4, projector)
    }

    /**
     Creates a `Selector` from five `Selector`s and a `projector` closure.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter s5Value: The `Value` from the fifth `Selector`
     */
    static func with<S1Value, S2Value, S3Value, S4Value, S5Value>(id: String = UUID().uuidString,
                                                                  _ selector1: Selector<State, S1Value, Void>,
                                                                  _ selector2: Selector<State, S2Value, Void>,
                                                                  _ selector3: Selector<State, S3Value, Void>,
                                                                  _ selector4: Selector<State, S4Value, Void>,
                                                                  _ selector5: Selector<State, S5Value, Void>,
                                                                  _ projector: @escaping (_ s1Value: S1Value,
                                                                                          _ s2Value: S2Value,
                                                                                          _ s3Value: S3Value,
                                                                                          _ s4Value: S4Value,
                                                                                          _ s5Value: S5Value) -> Value)
        -> Selector5<State, S1Value, S2Value, S3Value, S4Value, S5Value, Value, Void> {
        .init(id: id, selector1, selector2, selector3, selector4, selector5, projector)
    }
}

public extension Selector {
    static func with(
                     _ projector: @escaping (State, Input) -> Value)
        -> Selector<State, Value, Input> {
        return .init(projector: projector)
    }

    /**
     Creates a `Selector` from a `Selector` and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter input: The `Input` for the mapping
     - Returns: A `Selector` from the given `Selector` and the `projector` closure
     */
    static func with<S1Value>(id: String = UUID().uuidString,
                              _ selector1: Selector<State, S1Value, Void>,
                              _ projector: @escaping (_ s1Value: S1Value, _ input: Input) -> Value)
        -> Selector1<State, S1Value, Value, Input> {
        return .init(id: id, selector1, projector)
    }

    /**
     Creates a `Selector` from two `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter input: The `Input` for the mapping
     - Returns: A `Selector` from the given `Selector`s and the `projector` closure
     */
    static func with<S1Value, S2Value>(id: String = UUID().uuidString,
                                       _ selector1: Selector<State, S1Value, Void>,
                                       _ selector2: Selector<State, S2Value, Void>,
                                       _ projector: @escaping (_ s1Value: S1Value,
                                                               _ s2Value: S2Value,
                                                               _ input: Input) -> Value)
        -> Selector2<State, S1Value, S2Value, Value, Input> {
        .init(id: id, selector1, selector2, projector)
    }

    /**
     Creates a `Selector` from three `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter input: The `Input` for the mapping
     */
    static func with<S1Value, S2Value, S3Value>(id: String = UUID().uuidString,
                                                _ selector1: Selector<State, S1Value, Void>,
                                                _ selector2: Selector<State, S2Value, Void>,
                                                _ selector3: Selector<State, S3Value, Void>,
                                                _ projector: @escaping (_ s1Value: S1Value,
                                                                        _ s2Value: S2Value,
                                                                        _ s3Value: S3Value,
                                                                        _ input: Input) -> Value)
        -> Selector3<State, S1Value, S2Value, S3Value, Value, Input> {
        .init(id: id, selector1, selector2, selector3, projector)
    }

    /**
     Creates a `Selector` from four `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter input: The `Input` for the mapping
     */
    static func with<S1Value, S2Value, S3Value, S4Value>(id: String = UUID().uuidString,
                                                         _ selector1: Selector<State, S1Value, Void>,
                                                         _ selector2: Selector<State, S2Value, Void>,
                                                         _ selector3: Selector<State, S3Value, Void>,
                                                         _ selector4: Selector<State, S4Value, Void>,
                                                         _ projector: @escaping (_ s1Value: S1Value,
                                                                                 _ s2Value: S2Value,
                                                                                 _ s3Value: S3Value,
                                                                                 _ s4Value: S4Value,
                                                                                 _ input: Input) -> Value)
        -> Selector4<State, S1Value, S2Value, S3Value, S4Value, Value, Input> {
        .init(id: id, selector1, selector2, selector3, selector4, projector)
    }

    /**
     Creates a `Selector` from five `Selector`s and a `projector` closure which takes an `Input`.

     - Parameter id: An unique identifier for the `Selector`
     - Parameter selector1: The first `Selector`
     - Parameter selector2: The second `Selector`
     - Parameter selector3: The third `Selector`
     - Parameter selector4: The fourth `Selector`
     - Parameter selector5: The fifth `Selector`
     - Parameter projector: The `projector` closure to create the `Selector` from
     - Parameter s1Value: The `Value` from the first `Selector`
     - Parameter s2Value: The `Value` from the second `Selector`
     - Parameter s3Value: The `Value` from the third `Selector`
     - Parameter s4Value: The `Value` from the fourth `Selector`
     - Parameter s5Value: The `Value` from the fifth `Selector`
     - Parameter input: The `Input` for the mapping
     */
    static func with<S1Value, S2Value, S3Value, S4Value, S5Value>(id: String = UUID().uuidString,
                                                                  _ selector1: Selector<State, S1Value, Void>,
                                                                  _ selector2: Selector<State, S2Value, Void>,
                                                                  _ selector3: Selector<State, S3Value, Void>,
                                                                  _ selector4: Selector<State, S4Value, Void>,
                                                                  _ selector5: Selector<State, S5Value, Void>,
                                                                  _ projector: @escaping (_ s1Value: S1Value,
                                                                                          _ s2Value: S2Value,
                                                                                          _ s3Value: S3Value,
                                                                                          _ s4Value: S4Value,
                                                                                          _ s5Value: S5Value,
                                                                                          _ input: Input) -> Value)
        -> Selector5<State, S1Value, S2Value, S3Value, S4Value, S5Value, Value, Input> {
        .init(id: id, selector1, selector2, selector3, selector4, selector5, projector)
    }
}

internal extension Selector {
    /**
     Sets the value and the corresponding `stateHash`.

     - Parameter value: The value to save
     - Parameter stateHash: The hash of the state the value was selected from
     */
    func setResult(value: Value, forStateHash stateHash: UUID, input: Input?) {
        result = (stateHash: stateHash, input: input, value: value)
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
    func _map(_ state: State, stateHash: UUID, input: Input) -> Value {
        let value = map(state, input: input)
        setResult(value: value, forStateHash: stateHash, input: input)
        return value
    }
}

internal extension Selector where Input == Void {
    func map(_ state: State, stateHash: UUID) -> Value {
        if let result = result, result.stateHash == stateHash {
            return result.value
        }
        return _map(state, stateHash: stateHash, input: Void())
    }
}

internal extension Selector where Input: Hashable {
    func map(_ state: State, stateHash: UUID, input: Input) -> Value {
        if let result = result, result.stateHash == stateHash, result.input.hashValue == input.hashValue {
            return result.value
        }
        return _map(state, stateHash: stateHash, input: input)
    }
}
