//
//  Store.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 18/09/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import AnyCodable
import Combine
import Foundation

public struct InitialAction: Action {
    public var encodablePayload: [String: AnyEncodable]?
    public init() {}
}

public class Store<State: Encodable>: ObservableObject {
    @Published internal var state: State
    @Published internal var action: Action
    internal var reducers = [Reducer<State>]()
    internal var effectCancellables = Set<AnyCancellable>()
    internal var interceptors = [AnyStoreInterceptor<State>]()

    public init(initialState: State) {
        state = initialState
        action = InitialAction()
    }

    public func dispatch(action: Action) {
        state = reducers.reduce(state) { $1.reduce($0, action) }
        interceptors.forEach { interceptor in
            interceptor.actionDispatched(action: action, newState: state)
        }
        self.action = action
    }

    public func register(reducer: Reducer<State>) {
        reducers.append(reducer)
    }

    public func register(effects: Effects.Type) {
        effects.init($action).effects.forEach {
            $0.sink(receiveValue: { action in
                DispatchQueue.main.async {
                    self.dispatch(action: action)
                }
            }).store(in: &effectCancellables)
        }
    }

    public func register<S: StoreInterceptor>(interceptor: S) where S.State == State {
        interceptors.append(AnyStoreInterceptor<State>(interceptor))
    }

    public func select<Value>(_ selector: @escaping (State) -> Value) -> AnyPublisher<Value, Never> {
        return $state.map(selector).eraseToAnyPublisher()
    }

    public func select<Value>(_ keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        return select { (state: State) -> Value in
            state[keyPath: keyPath]
        }
    }

    public func selectCurrent<Value>(_ selector: @escaping (State) -> Value) -> Value {
        return selector(state)
    }

    public func selectCurrent<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        return state[keyPath: keyPath]
    }
}
