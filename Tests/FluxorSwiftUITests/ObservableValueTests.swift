/**
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
        ),
    ])

    func testBindingWithOneActionTemplate() {
        let observableValue = store.observe(counterSelector)
        XCTAssertEqual(observableValue.current, 42)
        store.dispatch(action: increment(payload: 1))
        XCTAssertEqual(observableValue.current, 43)
    }
}

private struct TestState: Encodable {
    var counter: Int = 42
}
