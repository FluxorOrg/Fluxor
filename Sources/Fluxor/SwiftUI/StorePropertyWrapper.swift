/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Combine
import Foundation

/// A type containing all the `Store`s to be used in property wrappers
public enum StorePropertyWrapper {
    private static var stores = [String: Any]()

    /**
     Add a `Store` instance to be used in property wrappers.
     
     - Parameter store: The `Store` to add, to be used by property wrappers
     */
    public static func addStore<State, Environment>(_ store: Store<State, Environment>) {
        stores[String(describing: type(of: store.state))] = AnyEnvironmentStore(store: store)
    }

    internal static func removeAllStores() {
        stores = [:]
    }

    internal static func getStore<State>() throws -> AnyEnvironmentStore<State> {
        let key = String(describing: State.self)
        guard let store = stores[key] as? AnyEnvironmentStore<State> else {
            throw StorePropertyWrapperError.storeNotFound(stateName: key)
        }
        return store
    }
}

/// The types of errors that can occur in `StorePropertyWrapper`.
public enum StorePropertyWrapperError: Error {
    /// A `Store` with the given `State` type couldn't be found.
    case storeNotFound(stateName: String)

    var localizedDescription: String {
        switch self {
        case .storeNotFound(let stateName):
            return "A Store for '\(stateName)' is not added to \(String(describing: StorePropertyWrapper.self))"
        }
    }
}

internal struct AnyEnvironmentStore<State> {
    let getState: () -> State
    let getStateHash: () -> UUID
    let getStatePublisher: () -> Published<State>.Publisher

    init<Environment>(store: Store<State, Environment>) {
        self.getState = { store.state }
        self.getStateHash = { store.stateHash }
        self.getStatePublisher = { store.$state }
    }

    func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        return Store<State, Any>.select(selector, statePublisher: getStatePublisher(), getStateHash: getStateHash)
    }

    func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        return Store<State, Any>.selectCurrent(selector, state: getState(), stateHash: getStateHash())
    }
}

#endif
