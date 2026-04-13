/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A type which mutates a `State` in response to dispatched actions.
public struct Reducer<State> {
    public let id: String
    private let reducer: (inout State, any Action) -> Void

    public init(
        id: String = UUID().uuidString,
        reduce: @escaping (_ state: inout State, _ action: any Action) -> Void
    ) {
        self.id = id
        reducer = reduce
    }

    public init(id: String = UUID().uuidString, _ reduceOns: ReduceOn<State>...) {
        self.id = id
        reducer = { state, action in
            reduceOns.forEach { $0.reduce(&state, action) }
        }
    }

    public func reduce(_ state: inout State, action: any Action) {
        reducer(&state, action)
    }
}

/// A typed part of a reducer that only runs for a specific action type.
public struct ReduceOn<State> {
    let reduce: (inout State, any Action) -> Void

    public init<A: Action>(
        _ actionType: A.Type,
        reduce: @escaping (_ state: inout State, _ action: A) -> Void
    ) {
        self.reduce = { state, action in
            guard let action = action as? A else { return }
            reduce(&state, action)
        }
    }
}
