/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation
#if canImport(Observation)
import Observation
#endif

/**
 The `Store` is a centralized container for a single source of truth `State`.

 `Action`s are sent to the store, reducers mutate state synchronously, interceptors observe
 the transition, and matching effects run asynchronously as follow up work.
 */
#if canImport(Observation)
@Observable
#endif
@MainActor
public final class Store<State: Sendable, Environment: Sendable> {
    public private(set) var state: State
    public let environment: Environment

    private var reducers = [KeyedReducer<State>]()
    private var effectRegistrations = [String: [Effect<State, Environment>]]()
    private var runningEffectTasks = [String: [UUID: Task<Void, Never>]]()
    private var interceptors = [AnyInterceptor<State>]()
    private var stateObservers = [UUID: @Sendable (State) -> Void]()
    private var actionObservers = [UUID: @Sendable (any Action) -> Void]()

    public init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        state = initialState
        self.environment = environment
        reducers.forEach(register(reducer:))
    }

    public func send(_ action: some Action) {
        send(erasing: action)
    }

    public func send(erasing action: any Action) {
        let oldState = state
        var newState = oldState

        reducers.forEach { $0.reduce(&newState, action) }
        state = newState
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: newState) }
        actionObservers.values.forEach { $0(action) }
        stateObservers.values.forEach { $0(newState) }
        launchEffects(for: action)
    }

    public func current<Value>(_ selector: Selector<State, Value>) -> Value {
        selector.map(state)
    }

    public func states() -> AsyncStream<State> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            continuation.yield(state)
            stateObservers[id] = { continuation.yield($0) }
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor in
                    self?.stateObservers.removeValue(forKey: id)
                }
            }
        }
    }

    public func actions() -> AsyncStream<any Action> {
        AsyncStream(bufferingPolicy: .unbounded) { continuation in
            let id = UUID()
            actionObservers[id] = { continuation.yield($0) }
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor in
                    self?.actionObservers.removeValue(forKey: id)
                }
            }
        }
    }

    public func select<Value: Sendable>(_ selector: Selector<State, Value>) -> AsyncStream<Value> {
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            continuation.yield(selector.map(state))
            stateObservers[id] = { nextState in
                continuation.yield(selector.map(nextState))
            }
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor in
                    self?.stateObservers.removeValue(forKey: id)
                }
            }
        }
    }

    public func register(reducer: Reducer<State>) {
        register(reducer: reducer, for: \.self)
    }

    public func register<Substate>(
        reducer: Reducer<Substate>,
        for keyPath: WritableKeyPath<State, Substate>
    ) {
        reducers.append(KeyedReducer(keyPath: keyPath, reducer: reducer))
    }

    public func unregister<SomeState>(reducer: Reducer<SomeState>) {
        reducers.removeAll { $0.id == reducer.id }
    }

    public func register<E: Effects>(effects: E) where E.State == State, E.Environment == Environment {
        register(effects: effects.effects, id: E.id)
    }

    public func register(effects: [Effect<State, Environment>], id: String = "*") {
        effectRegistrations[id] = effects
    }

    public func register(effect: Effect<State, Environment>, id: String = "*") {
        effectRegistrations[id, default: []].append(effect)
    }

    public func unregisterEffects<E: Effects>(ofType effectsType: E.Type)
    where E.State == State, E.Environment == Environment {
        unregisterEffects(withId: effectsType.id)
    }

    public func unregisterEffects(withId id: String) {
        effectRegistrations.removeValue(forKey: id)
        runningEffectTasks[id]?.values.forEach { $0.cancel() }
        runningEffectTasks.removeValue(forKey: id)
    }

    public func register<I: Interceptor>(interceptor: I) where I.State == State {
        interceptors.append(AnyInterceptor(interceptor))
    }

    public func unregisterInterceptors<I: Interceptor>(ofType interceptorType: I.Type) where I.State == State {
        interceptors.removeAll { $0.originalId == interceptorType.id }
    }

    private func launchEffects(for action: any Action) {
        for (registrationId, effects) in effectRegistrations {
            for effect in effects {
                let taskId = UUID()
                let context = EffectContext(store: self)
                let task = Task { @MainActor [weak self] in
                    defer { self?.removeEffectTask(taskId, registrationId: registrationId) }
                    _ = await effect.handleAction(action, context)
                }
                runningEffectTasks[registrationId, default: [:]][taskId] = task
            }
        }
    }

    private func removeEffectTask(_ taskId: UUID, registrationId: String) {
        runningEffectTasks[registrationId]?.removeValue(forKey: taskId)
        if runningEffectTasks[registrationId]?.isEmpty == true {
            runningEffectTasks.removeValue(forKey: registrationId)
        }
    }
}

public extension Store where Environment == Void {
    convenience init(initialState: State, reducers: [Reducer<State>] = []) {
        self.init(initialState: initialState, environment: (), reducers: reducers)
    }
}

private struct KeyedReducer<State> {
    let id: String
    let reduce: (inout State, any Action) -> Void

    init<Substate>(keyPath: WritableKeyPath<State, Substate>, reducer: Reducer<Substate>) {
        id = reducer.id
        reduce = { state, action in
            var substate = state[keyPath: keyPath]
            reducer.reduce(&substate, action: action)
            state[keyPath: keyPath] = substate
        }
    }
}
