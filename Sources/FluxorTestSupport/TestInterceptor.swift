/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import Foundation

@MainActor
public final class TestInterceptor<State>: Interceptor {
    public typealias StateChange = (action: any Action, oldState: State, newState: State)

    public private(set) var stateChanges = [StateChange]()

    public init() {}

    public func actionDispatched(action: any Action, oldState: State, newState: State) {
        stateChanges.append((action, oldState, newState))
    }

    public func waitForActions(
        expectedNumberOfActions: Int,
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10)
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout

        while stateChanges.count < expectedNumberOfActions {
            guard clock.now < deadline else {
                throw WaitingError.expectedCountNotReached(
                    message: "Timed out waiting for \(expectedNumberOfActions) actions. Received only \(stateChanges.count)."
                )
            }
            try await Task.sleep(for: pollInterval)
        }
    }

    public enum WaitingError: Error, Equatable {
        case expectedCountNotReached(message: String)
    }
}
