/*
 * FluxorSwiftUITests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import FluxorSwiftUI
import XCTest

class ObservableValueTests: XCTestCase {
    private let counterSelector = Selector(keyPath: \TestState.counter)
    private let increment = ActionTemplate(id: "Increment", payloadType: Int.self)
    private lazy var store = Store(initialState: TestState(), reducers: [
        Reducer<TestState>(
            ReduceOn(increment) { state, action in
                state.counter += action.payload
            }
        )
    ])

    func testBindingWithOneActionTemplate() {
        // Given
        let expectation = XCTestExpectation(description: debugDescription)
        let observableValue = store.observe(counterSelector)
        let cancellable = observableValue.objectWillChange.sink { expectation.fulfill() }
        XCTAssertEqual(observableValue.current, 42)
        // When
        store.dispatch(action: increment(payload: 1))
        // Then
        XCTAssertEqual(observableValue.current, 43)
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(cancellable)
    }
}

private struct TestState {
    var counter: Int = 42
}
