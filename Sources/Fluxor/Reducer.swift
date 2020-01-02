/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A pure functions which takes the current `State` and an `Action` and returns a new `State`.
public struct Reducer<State> {
    public let reduce: (State, Action) -> State

    public init(reduce: @escaping (State, Action) -> State) {
        self.reduce = reduce
    }
}
