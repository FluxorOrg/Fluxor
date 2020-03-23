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

public func createReducer<State, A: Action>(_ reduceOn: ReduceOnAction<State, A>) -> Reducer<State> {
    return Reducer<State> { state, action in
        if let action = action as? A {
            reduceOn.reduce(&state, action)
        }
    }
}

public func createReducer<State, C: ActionCreator>(_ reduceOn: ReduceOnActionCreator<State, C>) -> Reducer<State> {
    return Reducer<State> { state, action in
        if let anonymousAction = action as? AnonymousAction,
            let action = anonymousAction.asCreated(by: reduceOn.actionCreator) {
            reduceOn.reduce(&state, action)
        }
    }
}

public func reduceOn<State, A: Action>(_ actionType: A.Type, reduce: @escaping (inout State, A) -> Void) -> ReduceOnAction<State, A> {
    return ReduceOnAction<State, A>(actionType: actionType, reduce: reduce)
}

public func reduceOn<State, C: ActionCreator>(_ actionCreator: C, reduce: @escaping (inout State, C.ActionType) -> Void) -> ReduceOnActionCreator<State, C> {
    return ReduceOnActionCreator<State, C>(actionCreator: actionCreator, reduce: reduce)
}

/// A `Reducer` created from a `reduce` function.
public struct Reducer<State> {
    public let reduce: (inout State, Action) -> Void
}

public struct ReduceOnAction<State, A: Action> {
    public let actionType: A.Type
    public let reduce: (inout State, A) -> Void
}

public struct ReduceOnActionCreator<State, C: ActionCreator> {
    public let actionCreator: C
    public let reduce: (inout State, C.ActionType) -> Void
}
