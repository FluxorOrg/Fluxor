/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

class StoreValueTests: XCTestCase {
    private let counterSelector = Selector(keyPath: \TestState.counter)
    private let increment = ActionTemplate(id: "Increment", payloadType: Int.self)
    private var store: Store<TestState, Void>!

    override func setUp() {
        super.setUp()
        store = Store(initialState: .init(), reducers: [
            Reducer(
                ReduceOn(increment) { state, action in
                    state.counter += action.payload
                }
            )
        ])
        StorePropertyWrapper.removeAllStores()
        StorePropertyWrapper.addStore(store)
    }

    func testStoreValue() {
        // Given
        @StoreValue(counterSelector) var storeValue: Int
        XCTAssertEqual(storeValue, 42)
        // When
        store.dispatch(action: increment(payload: 1))
        // Then
        XCTAssertEqual(storeValue, 43)
    }
}

private struct TestState {
    var counter: Int = 42
}
