/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Combine
import Foundation

public enum StorePropertyWrapper {
    private static var stores = [String: Any]()

    public static func addStore<State, Environment>(_ store: Store<State, Environment>) {
        stores[String(describing: type(of: store.state))] = AnyEnvironmentStore(store: store)
    }

    static func getStore<State, Value>(for: Selector<State, Value>) -> AnyEnvironmentStore<State> {
        let key = String(describing: State.self)
        return stores[key] as! AnyEnvironmentStore<State>
    }
}

internal struct AnyEnvironmentStore<State>: ObservableStore {
    let getState: () -> State
    let getStateHash: () -> UUID
    let getStatePublisher: () -> Published<State>.Publisher
    let dispatchAction: (Action) -> Void

    init<Environment>(store: Store<State, Environment>) {
        self.getState = { store.state }
        self.getStateHash = { store.stateHash }
        self.getStatePublisher = { store.$state }
        self.dispatchAction = store.dispatch(action:)
    }

    func dispatch(action: Action) {
        dispatchAction(action)
    }

    func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        return Store<State, Any>.select(selector, statePublisher: getStatePublisher(), getStateHash: getStateHash)
    }

    func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return Store<State, Any>.selectCurrent(selector, state: getState(), stateHash: getStateHash())
    }

    func observe<Value>(_ selector: Selector<State, Value>) -> ObservableValue<Value> {
        return ObservableValue(current: selectCurrent(selector), publisher: select(selector))
    }
}

#endif
