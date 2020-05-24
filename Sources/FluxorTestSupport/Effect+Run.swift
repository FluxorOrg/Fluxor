/*
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Dispatch
import Fluxor
import XCTest

public extension Effect {
    /// `Error`s which can be thrown when running `Effect`s
    enum RunError: Error {
        /// The `Effect` can't be run this way
        case wrongType
    }

    /**
     Run the `Effect` with the specified `Action` and return the published `Action`s.

     The `expectedCount` defines how many `Action`s the `Publisher` should publish before they are returned.

     - Parameter action: The `Action` to send to the `Effect`
     - Parameter expectedCount: The count of `Action`s to wait for
     */
    func run(with action: Action, expectedCount: Int = 1) throws -> [Action] {
        let actions = PassthroughSubject<Action, Never>()
        let recorder = ActionRecorder(numberOfActions: expectedCount)
        let publisher: AnyPublisher<[Action], Never>
        switch self {
        case .dispatchingOne(let effectCreator):
            publisher = effectCreator(actions.eraseToAnyPublisher()).map { [$0] }.eraseToAnyPublisher()
        case .dispatchingMultiple(let effectCreator):
            publisher = effectCreator(actions.eraseToAnyPublisher())
        case .nonDispatching:
            throw RunError.wrongType
        }
        publisher.subscribe(recorder)
        actions.send(action)
        try recorder.waitForAllActions()
        return recorder.actions
    }

    /**
     Run the `Effect` with the specified `Action`.

     - Parameter action: The `Action` to send to the `Effect`
     */
    func run(with action: Action) {
        let actions = PassthroughSubject<Action, Never>()
        guard case .nonDispatching(let effectCreator) = self else { return }
        var cancellables: [AnyCancellable] = []
        effectCreator(actions.eraseToAnyPublisher()).store(in: &cancellables)
        actions.send(action)
    }
}

/**
 The `ActionRecorder` records published `Action`s from a `Publisher`.

 Inspired by: https://vojtastavik.com/2019/12/11/combine-publisher-blocking-recorder/
 */
private class ActionRecorder {
    typealias Input = [Action]
    typealias Failure = Never

    enum RecordingError: Error {
        case expectedCountNotReached(message: String)
    }

    private let expectation = XCTestExpectation()
    private let waiter = XCTWaiter()
    private(set) var actions = [Action]() { didSet { expectation.fulfill() } }

    init(numberOfActions: Int) {
        expectation.expectedFulfillmentCount = numberOfActions
    }

    /**
     Wait for all the expected `Action`s to be published.

     - Parameter timeout: The time waiting for the `Action`s
     */
    func waitForAllActions(timeout: TimeInterval = 1) throws {
        guard actions.count < expectation.expectedFulfillmentCount else { return }
        let waitResult = waiter.wait(for: [expectation], timeout: timeout)
        if waitResult != .completed {
            func valueFormatter(_ count: Int) -> String {
                "\(count) action" + (count == 1 ? "" : "s")
            }
            let formattedNumberOfActions = valueFormatter(expectation.expectedFulfillmentCount)
            let formattedActions = valueFormatter(actions.count)

            let errorMessage = "Waiting for \(formattedNumberOfActions) timed out. Received only \(formattedActions)."
            throw RecordingError.expectedCountNotReached(message: errorMessage)
        }
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
