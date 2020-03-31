/**
 * FluxorTestSupport
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Dispatch
import Fluxor
import XCTest

public extension DispatchingEffectCreator {
    func run(with action: Action, expectedCount: Int = 1, file: StaticString = #file, line: UInt = #line) -> [Action] {
        let actions = PassthroughSubject<Action, Never>()
        let effect = createEffect(actionPublisher: actions.eraseToAnyPublisher())
        guard case .dispatching(let publisher) = effect else { return [] }
        let recorder = ActionRecorder(numberOfRecords: expectedActions)
        publisher.subscribe(recorder)
        actions.send(action)
        recorder.waitForAllActions()
        return recorder.actions
    }
}

public extension NonDispatchingEffectCreator {
    func run(with action: Action) {
        let actions = PassthroughSubject<Action, Never>()
        let effect = createEffect(actionPublisher: actions.eraseToAnyPublisher())
        guard case .nonDispatching = effect else { return }
        actions.send(action)
    }
}

/**
 The `ActionRecorder` records published `Action`s from a `Publisher`.

 Inspired by: https://vojtastavik.com/2019/12/11/combine-publisher-blocking-recorder/
 */
private class ActionRecorder: Subscriber {
    typealias Input = Action
    typealias Failure = Never

    private let expectation = XCTestExpectation()
    private let waiter = XCTWaiter()
    private(set) var actions = [Action]() { didSet { expectation.fulfill() } }

    init(numberOfRecords: Int) {
        expectation.expectedFulfillmentCount = numberOfRecords
    }

    func waitForAllActions(timeout: TimeInterval = 1, file: StaticString = #file, line: UInt = #line) {
        guard actions.count < expectation.expectedFulfillmentCount else { return }
        let waitResult = waiter.wait(for: [expectation], timeout: timeout)
        if waitResult != .completed {
            func valueFormatter(_ count: Int) -> String {
                "\(count) action" + (count == 1 ? "" : "s")
            }
            let formattedNumberOfActions = valueFormatter(expectation.expectedFulfillmentCount)
            let formattedActions = valueFormatter(actions.count)

            XCTFail("Waiting for \(formattedNumberOfActions) timed out. Received only \(formattedActions).",
                    file: file, line: line)
        }
    }

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        DispatchQueue.main.async {
            self.actions.append(input)
        }
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {}
}
