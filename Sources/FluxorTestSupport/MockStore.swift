/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Foundation
import Fluxor

@MainActor
public final class MockStore<State: Sendable, Environment: Sendable> {
    public var state: State { store.state }
    public var stateChanges: [TestInterceptor<State>.StateChange] { interceptor.stateChanges }
    public var dispatchedActions: [any Action] { stateChanges.map(\.action) }

    public let store: Store<State, Environment>

    private var overriddenSelectorValues = [UUID: Any]()
    private let interceptor = TestInterceptor<State>()

    public init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        store = Store(initialState: initialState, environment: environment, reducers: reducers)
        store.register(interceptor: interceptor)
    }

    public convenience init(initialState: State, reducers: [Reducer<State>] = []) where Environment == Void {
        self.init(initialState: initialState, environment: (), reducers: reducers)
    }

    public func send(_ action: some Action) {
        store.send(action)
    }

    public func current<Value>(_ selector: Fluxor.Selector<State, Value>) -> Value {
        if let overriddenValue = overriddenSelectorValues[selector.id] as? Value {
            overriddenValue
        } else {
            store.current(selector)
        }
    }

    public func select<Value: Sendable>(_ selector: Fluxor.Selector<State, Value>) -> AsyncStream<Value> {
        if let overriddenValue = overriddenSelectorValues[selector.id] as? Value {
            let states = store.states()
            return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
                let task = Task { @MainActor in
                    continuation.yield(overriddenValue)
                    var iterator = states.makeAsyncIterator()
                    _ = await iterator.next()
                    while !Task.isCancelled, await iterator.next() != nil {
                        continuation.yield(overriddenValue)
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }

        return store.select(selector)
    }

    public func overrideSelector<Value>(_ selector: Fluxor.Selector<State, Value>, value: Value) {
        overriddenSelectorValues[selector.id] = value
    }

    public func resetOverriddenSelectors() {
        overriddenSelectorValues.removeAll()
    }
}
