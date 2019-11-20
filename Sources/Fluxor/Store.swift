//
//  Store.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 18/09/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import AnyCodable
import Combine

public struct InitialAction: Action {
    public var encodablePayload: [String: AnyEncodable]?
    public init() {}
}

public class Store<State: Encodable>: ObservableObject {
    @Published internal var state: State
    @Published internal var action: Action
    internal var reducers = [Reducer<State, Action>]()
    internal var effectCancellables = Set<AnyCancellable>()
    internal var interceptors = [AnyStoreInterceptor<State>]()

    public init(initialState: State) {
        state = initialState
        action = InitialAction()
    }

    public func dispatch(action: Action) {
        self.action = action
        state = reducers.reduce(state) { $1.reduce($0, action) }
        interceptors.forEach { interceptor in
            interceptor.actionDispatched(action: action, newState: state)
        }
    }

    public func register(reducer: Reducer<State, Action>) {
        reducers.append(reducer)
    }

    public func register(effects: Effects.Type) {
        effects.init($action).effects.forEach {
            $0.sink(receiveValue: dispatch(action:)).store(in: &effectCancellables)
        }
    }

    public func register<S: StoreInterceptor>(interceptor: S) where S.State == State {
        interceptors.append(AnyStoreInterceptor<State>(interceptor))
    }

    public func select<T>(_ selector: @escaping (State) -> T) -> Publishers.Map<Published<State>.Publisher, T> {
        return $state.map(selector)
    }
}
