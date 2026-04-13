/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import Foundation

@MainActor
public enum EffectRunner {
    @discardableResult
    public static func run<State: Sendable, Environment: Sendable>(
        _ effect: Effect<State, Environment>,
        with action: some Action,
        initialState: State,
        environment: Environment,
        expectedCount: Int = 1,
        timeout: Duration = .seconds(1)
    ) async throws -> [any Action] {
        let store = Store(initialState: initialState, environment: environment)
        let interceptor = TestInterceptor<State>()
        store.register(effect: effect, id: "effect-runner")
        store.register(interceptor: interceptor)
        store.send(action)

        try await interceptor.waitForActions(expectedNumberOfActions: expectedCount + 1, timeout: timeout)
        return Array(interceptor.stateChanges.dropFirst().map(\.action))
    }

    @discardableResult
    public static func run<State: Sendable>(
        _ effect: Effect<State, Void>,
        with action: some Action,
        initialState: State,
        expectedCount: Int = 1,
        timeout: Duration = .seconds(1)
    ) async throws -> [any Action] {
        try await run(
            effect,
            with: action,
            initialState: initialState,
            environment: (),
            expectedCount: expectedCount,
            timeout: timeout
        )
    }
}
