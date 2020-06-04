/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Dispatch
import Fluxor
import XCTest

/// The `EffectRunner` can be used to run `Effect`s with a specified `Action`.
public struct EffectRunner<Environment> {
    /**
     Run the `Effect` with the specified `Action` and return the published `Action`s.

     The `expectedCount` defines how many `Action`s the `Publisher` should publish before they are returned.
     If the `Effect` is `.nonDispatching`, the `expectedCount` is ignored.

     - Parameter effect: The `Effect` to run
     - Parameter action: The `Action` to send to the `Effect`
     - Parameter environment: The `Environment` to send to the `Effect`
     - Parameter expectedCount: The count of `Action`s to wait for
     - Returns: The `Action`s published by the `Effect` if it is dispatching
     */
    @discardableResult
    public static func run(_ effect: Effect<Environment>,
                           with action: Action,
                           environment: Environment,
                           expectedCount: Int = 1) throws -> [Action]? {
        let actions = PassthroughSubject<Action, Never>()
        let runDispatchingEffect = { (publisher: AnyPublisher<[Action], Never>) throws -> [Action] in
            let recorder = ActionRecorder(expectedNumberOfActions: expectedCount)
            publisher.subscribe(recorder)
            actions.send(action)
            return try recorder.waitForAllActions()
        }
        switch effect {
        case .dispatchingOne(let effectCreator):
            return try runDispatchingEffect(effectCreator(actions.eraseToAnyPublisher(), environment)
                .map { [$0] }.eraseToAnyPublisher())
        case .dispatchingMultiple(let effectCreator):
            return try runDispatchingEffect(effectCreator(actions.eraseToAnyPublisher(), environment))
        case .nonDispatching(let effectCreator):
            var cancellables: [AnyCancellable] = []
            effectCreator(actions.eraseToAnyPublisher(), environment).store(in: &cancellables)
            actions.send(action)
            return nil
        }
    }
}

public extension EffectRunner where Environment == Void {
    /**
     Run the `Effect` with the specified `Action` and return the published `Action`s.

     The `expectedCount` defines how many `Action`s the `Publisher` should publish before they are returned.
     If the `Effect` is `.nonDispatching`, the `expectedCount` is ignored.

     - Parameter effect: The `Effect` to run
     - Parameter action: The `Action` to send to the `Effect`
     - Parameter expectedCount: The count of `Action`s to wait for
     - Returns: The `Action`s published by the `Effect` if it is dispatching
     */
    @discardableResult
    static func run(_ effect: Effect<Environment>,
                    with action: Action,
                    expectedCount: Int = 1) throws -> [Action]? {
        return try run(effect, with: action, environment: Void(), expectedCount: expectedCount)
    }
}

/**
 The `ActionRecorder` records published `Action`s from a `Publisher`.

 Inspired by: https://vojtastavik.com/2019/12/11/combine-publisher-blocking-recorder/
 */
private class ActionRecorder {
    typealias Input = [Action]
    typealias Failure = Never
    private let expectation = XCTestExpectation()
    private(set) var actions = [Action]() { didSet { expectation.fulfill() } }

    /**
     Initializes an `ActionRecorder` with the given `expectedNumberOfActions`.

     - Parameter expectedNumberOfActions: The number of `Action`s to wait for
     */
    init(expectedNumberOfActions: Int) {
        expectation.expectedFulfillmentCount = expectedNumberOfActions
    }

    /**
     Wait for all the expected `Action`s to be published.

     - Parameter timeout: The time waiting for the `Action`s
     - Returns: The `Action`s recorded
     */
    func waitForAllActions(timeout: TimeInterval = 1) throws -> [Action] {
        guard actions.count < expectation.expectedFulfillmentCount else { return actions }
        let waitResult = XCTWaiter().wait(for: [expectation], timeout: timeout)
        guard waitResult != .completed else { return actions }

        let valueFormatter = { (count: Int) in "\(count) action" + (count == 1 ? "" : "s") }
        let formattedExpectedActions = valueFormatter(expectation.expectedFulfillmentCount)
        let formattedActions = valueFormatter(actions.count)
        let errorMessage = "Waiting for \(formattedExpectedActions) timed out. Received only \(formattedActions)."
        throw RecordingError.expectedCountNotReached(message: errorMessage)
    }

    enum RecordingError: Error {
        case expectedCountNotReached(message: String)
    }
}

extension ActionRecorder: Subscriber {
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        DispatchQueue.main.async {
            input.forEach { self.actions.append($0) }
        }
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {}
}
