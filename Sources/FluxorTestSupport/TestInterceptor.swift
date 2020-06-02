/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

// swiftlint:disable large_tuple

/// An `Interceptor` to use in unit tests, to assert specific `Action`s are dispatched.
public class TestInterceptor<State>: Interceptor {
    /// A list of `Action`s and `State`s intercepted.
    public private(set) var stateChanges: [(action: Action, oldState: State, newState: State)] = [] {
        didSet { expectation?.fulfill() }
    }

    private var expectation: XCTestExpectation?

    /// Initializes the `TestInterceptor`.
    public init() {}

    public func actionDispatched(action: Action, oldState: State, newState: State) {
        stateChanges.append((action, oldState, newState))
    }

    /**
     Waits for the expected number of `Action`s to be intercepted.
     If the expected number of `Action`s are not intercepted before the timout an error is thrown.

     - Parameter expectedNumberOfActions: The number of `Action`s to wait for
     - Parameter timeout: The waiting time before failing (in seconds)
     */
    public func waitForActions(expectedNumberOfActions: Int, timeout: TimeInterval = 1) throws {
        guard stateChanges.count < expectedNumberOfActions else { return }

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = expectedNumberOfActions - stateChanges.count
        self.expectation = expectation
        let waitResult = XCTWaiter().wait(for: [expectation], timeout: timeout)
        guard waitResult != .completed else { return }

        let valueFormatter = { (count: Int) in "\(count) action" + (count == 1 ? "" : "s") }
        let formattedExpectedActions = valueFormatter(expectation.expectedFulfillmentCount)
        let formattedActions = valueFormatter(stateChanges.count)
        let errorMessage = "Waiting for \(formattedExpectedActions) timed out. Received only \(formattedActions)."
        throw WaitingError.expectedCountNotReached(message: errorMessage)
    }

    /// Errors waiting for intercepted `Action`s
    public enum WaitingError: Error {
        case expectedCountNotReached(message: String)
    }
}
