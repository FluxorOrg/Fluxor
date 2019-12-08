//
//  StoreInterceptor.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 16/11/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

public protocol StoreInterceptor {
    associatedtype State
    func actionDispatched(action: Action, newState: State)
}

struct AnyStoreInterceptor<State>: StoreInterceptor {
    private let _actionDispatched: (Action, State) -> Void

    init<S: StoreInterceptor>(_ storeInterceptor: S) where S.State == State {
        _actionDispatched = storeInterceptor.actionDispatched
    }

    func actionDispatched(action: Action, newState: State) {
        _actionDispatched(action, newState)
    }
}

public class TestStoreInterceptor<State>: StoreInterceptor {
    public private(set) var dispatchedActionsAndStates: [(action: Action, newState: State)] = []

    public init() {}

    public func actionDispatched(action: Action, newState: State) {
        dispatchedActionsAndStates.append((action, newState))
    }
}
