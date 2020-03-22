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

/// A `Reducer` created from a `reduce` function.
public struct Reducer<State> {
    public let reduce: (inout State, Action) -> Void
}
