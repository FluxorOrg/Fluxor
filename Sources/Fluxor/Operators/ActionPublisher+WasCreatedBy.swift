/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine

extension Publisher where Output == Action {
    /**
     Only lets `Action`s created by the given `ActionCreator`s get through the stream.

         actions
             .wasCreated(by: fetchTodosActionCreator)
             .sink(receiveValue: { action in
                 print("This is a FetchTodosAction: \(action)")
             })

     - Parameter actionCreator: An `ActionCreator` to check
     */
    public func wasCreated<C: ActionCreator>(by actionCreator: C) -> AnyPublisher<C.ActionType, Self.Failure> {
        ofType(C.ActionType.self)
            .filter { $0.wasCreated(by: actionCreator) }
            .eraseToAnyPublisher()
    }
}
