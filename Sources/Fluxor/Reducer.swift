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

public func createReducer<State>(_ reduceOns: AnyReduceOn<State>...) -> Reducer<State> {
    return Reducer<State> { state, action in
        reduceOns.forEach { $0.reduce(&state, action) }
    }
}

public func reduceOn<State, A: Action>(_ actionType: A.Type, reduce: @escaping (inout State, A) -> Void) -> AnyReduceOn<State> {
    return AnyReduceOn { state, action in
        guard let action = action as? A else { return }
        ReduceOnAction<State, A>(actionType: actionType, reduce: reduce).reduce(&state, action)
    }
}

public func reduceOn<State, C: ActionCreator>(_ actionCreator: C, reduce: @escaping (inout State, C.ActionType) -> Void) -> AnyReduceOn<State> {
    return AnyReduceOn { state, action in
        guard let anonymousAction = action as? AnonymousAction,
            let action = anonymousAction.asCreated(by: actionCreator) else { return }
        ReduceOnActionCreator<State, C>(actionCreator: actionCreator, reduce: reduce).reduce(&state, action)
    }
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

public struct AnyReduceOn<State> {
    public let reduce: (inout State, Action) -> Void
}
