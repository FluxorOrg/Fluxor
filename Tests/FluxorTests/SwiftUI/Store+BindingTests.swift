/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

import Fluxor
import FluxorTestSupport
import SwiftUI
import XCTest

// swiftlint:disable force_cast

class StoreBindingTests: XCTestCase {
    private let counterSelector = Selector(keyPath: \TestState.counter)
    private let lockedSelector = Selector(keyPath: \TestState.locked)
    private let lightsOnSelector = Selector(keyPath: \TestState.lightsOn)
    private let setCounter = ActionTemplate(id: "Set", payloadType: Int.self)
    private let clearCounter = ActionTemplate(id: "Clear")
    private let doubleUpCounter = ActionTemplate(id: "Double up")
    private let lock = ActionTemplate(id: "Lock")
    private let unlock = ActionTemplate(id: "Unlock")
    private let changeLights = ActionTemplate(id: "Turn lights on/off", payloadType: Bool.self)
    private lazy var store = MockStore(initialState: TestState(), reducers: [
        Reducer<TestState>(
            ReduceOn(setCounter) { state, action in
                state.counter = action.payload
            },
            ReduceOn(clearCounter) { state, _ in
                state.counter = 0
            },
            ReduceOn(doubleUpCounter) { state, _ in
                state.counter *= 2
            },
            ReduceOn(lock) { state, _ in
                state.locked = true
            },
            ReduceOn(unlock) { state, _ in
                state.locked = false
            },
            ReduceOn(changeLights) { state, action in
                state.lightsOn = action.payload
            }
        )
    ])

    func testBindingWithOneActionTemplate() {
        // Given
        let newCounter = 1337
        let counterView = CounterView(counter: store.binding(get: counterSelector, send: setCounter))
        XCTAssertEqual(counterView.counter, 42)
        // When
        counterView.counter = newCounter
        // Then
        XCTAssertEqual(counterView.counter, newCounter)
        let action = store.stateChanges[0].action as! AnonymousAction<Int>
        XCTAssertTrue(action.wasCreated(from: setCounter))
        XCTAssertEqual(action.payload, newCounter)
    }

    func testBindingWithActionTemplateClosure() {
        // Given
        let counterView = CounterView(counter: store.binding(
            get: counterSelector, send: { $0 >= 43
                ? self.clearCounter()
                : self.doubleUpCounter()
            }
        ))
        XCTAssertEqual(counterView.counter, 42)
        // When
        counterView.counter = 1
        // Then
        XCTAssertEqual(counterView.counter, 84)

        // When
        counterView.counter = 44
        // Then
        XCTAssertEqual(counterView.counter, 0)
        let action1 = store.stateChanges[0].action as! AnonymousAction<Void>
        XCTAssertTrue(action1.wasCreated(from: doubleUpCounter))
        let action2 = store.stateChanges[1].action as! AnonymousAction<Void>
        XCTAssertTrue(action2.wasCreated(from: clearCounter))
    }

    func testBindingWithEnableDisable() {
        // Given
        let lockView = LockView(locked: store.binding(get: lockedSelector, enable: lock, disable: unlock))
        XCTAssertEqual(lockView.locked, false)
        // When
        lockView.locked = true
        // Then
        XCTAssertEqual(lockView.locked, true)

        // When
        lockView.locked = false
        // Then
        XCTAssertEqual(lockView.locked, false)
        let action1 = store.stateChanges[0].action as! AnonymousAction<Void>
        XCTAssertTrue(action1.wasCreated(from: lock))
        let action2 = store.stateChanges[1].action as! AnonymousAction<Void>
        XCTAssertTrue(action2.wasCreated(from: unlock))
    }

    func testBindingWithBoolUpdateValue() {
        // Given
        let lightsView = LightsView(lightsOn: store.binding(get: lightsOnSelector, send: changeLights))
        XCTAssertEqual(lightsView.lightsOn, false)
        // When
        lightsView.lightsOn = true
        // Then
        XCTAssertEqual(lightsView.lightsOn, true)

        // When
        lightsView.lightsOn = false
        // Then
        XCTAssertEqual(lightsView.lightsOn, false)
        let action1 = store.stateChanges[0].action as! AnonymousAction<Bool>
        XCTAssertTrue(action1.wasCreated(from: changeLights))
        XCTAssertEqual(action1.payload, true)
        let action2 = store.stateChanges[1].action as! AnonymousAction<Bool>
        XCTAssertTrue(action2.wasCreated(from: changeLights))
        XCTAssertEqual(action2.payload, false)
    }
}

private struct CounterView: View {
    @Binding var counter: Int
    var body: some View { Text("Counter: \(counter)") }
}

private struct LockView: View {
    @Binding var locked: Bool
    var body: some View { Text(locked ? "Locked" : "Unlocked") }
}

private struct LightsView: View {
    @Binding var lightsOn: Bool
    var body: some View { Text(lightsOn ? "On" : "Off") }
}

private struct TestState {
    var counter: Int = 42
    var locked: Bool = false
    var lightsOn: Bool = false
}

#endif
