/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which takes a `State` and `Action` returns a new `State`.
public struct Reducer<State> {
    public let reduce: (inout State, Action) -> Void

    /**
     Creates a `Reducer` from a `reduce` function.
     The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

     - Parameter reduce: The `reduce` function to create a `Reducer` from
     */
    public init(reduce: @escaping (inout State, Action) -> Void) {
        self.reduce = reduce
    }

    /**
     Creates a `Reducer` from a list of `OnReduce`s.

     - Parameter reduceOns: The `OnReduce`s which the created `Reducer` should contain
     */
    public init(_ reduceOns: ReduceOn<State>...) {
        self.reduce = { state, action in
            reduceOns.forEach { $0.reduce(&state, action) }
        }
    }
}

/// A part of a `Reducer` which only gets triggered on certain `Action`s or `ActionTemplate`s.
public struct ReduceOn<State> {
    public let reduce: (inout State, Action) -> Void

    /**
     Creates a `OnReduce` which only runs `reduce` with actions of the type specificed in `actionType`.
     The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

     - Parameter actionType: The type of `Action` to filter on
     - Parameter reduce: The `reduce` function to create a `OnReduce` from
     */
    public init<A: Action>(_ actionType: A.Type, reduce: @escaping (inout State, A) -> Void) {
        self.reduce = { state, action in
            guard let action = action as? A else { return }
            reduce(&state, action)
        }
    }

    /**
     Creates a `OnReduce` which only runs `reduce` with actions created from the `ActionTemplate` specificed.
     The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

     - Parameter actionTemplate: The `ActionTemplate` to filter on
     - Parameter reduce: The `reduce` function to create a `OnReduce` from
     */

    public init<Payload>(_ actionTemplate: ActionTemplate<Payload>,
                         reduce: @escaping (inout State, AnonymousAction<Payload>) -> Void) {
        self.reduce = { state, action in
            guard let anonymousAction = action as? AnonymousAction<Payload>,
                anonymousAction.wasCreated(from: actionTemplate) else { return }
            reduce(&state, anonymousAction)
        }
    }
}
