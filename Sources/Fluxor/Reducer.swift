/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/**
 Creates a `Reducer` from a `reduce` function.
 The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

 - Parameter reduce: The `reduce` function to create a `Reducer` from
 */
public func createReducer<State>(_ reduce: @escaping (inout State, Action) -> Void) -> Reducer<State> {
    return Reducer(reduce: reduce)
}

/**
 Creates a `Reducer` from a list of `OnReduce`s.

 - Parameter reduceOns: The `OnReduce`s which the created `Reducer` should contain
 */
public func createReducer<State>(_ reduceOns: OnReduce<State>...) -> Reducer<State> {
    return Reducer<State> { state, action in
        reduceOns.forEach { $0.reduce(&state, action) }
    }
}

/**
 Creates a `OnReduce` which only runs `reduce` with actions of the type specificed in `actionType`.
 The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

 - Parameter actionType: The type of `Action` to filter on
 - Parameter reduce: The `reduce` function to create a `OnReduce` from
 */
public func reduceOn<State, A: Action>(_ actionType: A.Type,
                                       reduce: @escaping (inout State, A) -> Void) -> OnReduce<State> {
    return OnReduce { state, action in
        guard let action = action as? A else { return }
        reduce(&state, action)
    }
}

/**
Creates a `OnReduce` which only runs `reduce` with actions created by the `ActionCreator` specificed.
The `reduce` function is a pure function which takes the current `State` and an `Action` and returns a new `State`.

- Parameter actionCreator: The `ActionCreator` to filter on
- Parameter reduce: The `reduce` function to create a `OnReduce` from
*/

public func reduceOn<State, C: ActionCreatorProtocol>(_ actionCreator: C,
                                              reduce: @escaping (inout State, C.ActionType) -> Void)
    -> OnReduce<State> {
    return OnReduce { state, action in
        guard let anonymousAction = action as? AnonymousAction,
            let action = anonymousAction.asCreated(by: actionCreator) else { return }
        reduce(&state, action)
    }
}

/// A `Reducer` created from a `reduce` function.
public struct Reducer<State> {
    public let reduce: (inout State, Action) -> Void
}

/// A `OnReduce` created from a `reduce` function.
public struct OnReduce<State> {
    public let reduce: (inout State, Action) -> Void
}
