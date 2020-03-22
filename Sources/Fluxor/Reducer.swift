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

public func createReducer<State, A: Action>(_ reduceOn: ReduceOn<State, A>) -> Reducer<State> {
    return Reducer<State> { state, action in
        if let action = action as? A {
            reduceOn.reduce(&state, action)
        }
    }
}

public func reduceOn<State, A: Action>(_ actionType: A.Type, reduce: @escaping (inout State, A) -> Void) -> ReduceOn<State, A> {
    return ReduceOn<State, A>(actionType: actionType, reduce: reduce)
}

/// A `Reducer` created from a `reduce` function.
public struct Reducer<State> {
    public let reduce: (inout State, Action) -> Void
}

public struct ReduceOn<State, A: Action> {
    public let actionType: A.Type
    public let reduce: (inout State, A) -> Void
}
