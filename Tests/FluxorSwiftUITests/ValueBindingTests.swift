/**
 * FluxorSwiftUITests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import FluxorSwiftUI
import XCTest

class ValueBindingTests: XCTestCase {
    private let counterSelector = Selector(keyPath: \TestState.counter)
    private let lockedSelector = Selector(keyPath: \TestState.locked)
    private let increment = ActionTemplate(id: "Increment", payloadType: Int.self)
    private let clear = ActionTemplate(id: "Clear")
    private let doubleUp = ActionTemplate(id: "Double up")
    private let lock = ActionTemplate(id: "Lock")
    private let unlock = ActionTemplate(id: "Unlock")
    private lazy var store = Store(initialState: TestState(), reducers: [
        Reducer<TestState>(
            ReduceOn(increment) { state, action in
                state.counter += action.payload
            },
            ReduceOn(clear) { state, _ in
                state.counter = 0
            },
            ReduceOn(doubleUp) { state, _ in
                state.counter *= 2
            },
            ReduceOn(lock) { state, _ in
                state.locked = true
            },
            ReduceOn(unlock) { state, _ in
                state.locked = false
            }
        )
    ])

    func testBindingWithOneActionTemplate() {
        let valueBinding = store.binding(get: counterSelector, set: increment)
        let binding = valueBinding.binding
        XCTAssertEqual(valueBinding.current, 42)
        XCTAssertEqual(binding.wrappedValue, 42)
        valueBinding.update(value: 1)
        XCTAssertEqual(valueBinding.current, 43)
        XCTAssertEqual(binding.wrappedValue, 43)
    }

    func testBindingWithActionTemplateClosure() {
        let valueBinding = store.binding(get: counterSelector, set: { $0 >= 43 ? self.clear : self.doubleUp })
        let binding = valueBinding.binding
        XCTAssertEqual(valueBinding.current, 42)
        XCTAssertEqual(binding.wrappedValue, 42)
        valueBinding.update()
        XCTAssertEqual(valueBinding.current, 84)
        XCTAssertEqual(binding.wrappedValue, 84)
        valueBinding.update()
        XCTAssertEqual(valueBinding.current, 0)
        XCTAssertEqual(binding.wrappedValue, 0)
    }

    func testBindingWithEnableDisable() {
        let valueBinding = store.binding(get: lockedSelector, enable: lock, disable: unlock)
        let binding = valueBinding.binding
        XCTAssertEqual(valueBinding.current, false)
        XCTAssertEqual(binding.wrappedValue, false)
        valueBinding.toggle()
        XCTAssertEqual(valueBinding.current, true)
        XCTAssertEqual(binding.wrappedValue, true)
        valueBinding.toggle()
        XCTAssertEqual(valueBinding.current, false)
        XCTAssertEqual(binding.wrappedValue, false)
    }
}

private struct TestState: Encodable {
    var counter: Int = 42
    var locked: Bool = false
}