/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which takes the current `State` and an `Action` and returns a new `State`.
public protocol Reducer {
    associatedtype State
    /// The function called when an `Action` is dispatched on a `Store`.
    func reduce(state: State, action: Action) -> State
}

/**
 Creates a `Reducer` from a `reduce` function.
 
 - Parameter reduce: The `reduce` function to create a `Reducer` from
 */
public func createReducer<State>(reduce: @escaping (State, Action) -> State) -> AnonymousReducer<State> {
    return AnonymousReducer(reduce: reduce)
}

/// An anonymous `Reducer` created from a `reduce` function.
public struct AnonymousReducer<State>: Reducer {
    let reduce: (State, Action) -> State
    
    public func reduce(state: State, action: Action) -> State {
        return self.reduce(state, action)
    }
}

/// A type-erased `Reducer` used to store all `Reducer`s in an array in the `Store`.
internal struct AnyReducer<State>: Reducer {
    private let _reduce: (State, Action) -> State

    init<R: Reducer>(_ reducer: R) where R.State == State {
        _reduce = reducer.reduce
    }

    func reduce(state: State, action: Action) -> State {
        return _reduce(state, action)
    }
}
