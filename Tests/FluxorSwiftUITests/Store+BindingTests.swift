/*
 * FluxorSwiftUITests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import FluxorSwiftUI
import FluxorTestSupport
import SwiftUI
import XCTest

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
        let newCounter = 1337
        let counterView = CounterView(counter: store.binding(get: counterSelector, send: setCounter))
        XCTAssertEqual(counterView.counter, 42)
        counterView.counter = newCounter
        XCTAssertEqual(counterView.counter, newCounter)
        let action = store.stateChanges[0].action as! AnonymousAction<Int>
        XCTAssertTrue(action.wasCreated(from: setCounter))
        XCTAssertEqual(action.payload, newCounter)
    }

    func testBindingWithActionTemplateClosure() {
        let counterView = CounterView(counter: store.binding(
            get: counterSelector, send: { $0 >= 43
                ? self.clearCounter()
                : self.doubleUpCounter()
            }
        ))
        XCTAssertEqual(counterView.counter, 42)
        counterView.counter = 1
        XCTAssertEqual(counterView.counter, 84)
        counterView.counter = 44
        XCTAssertEqual(counterView.counter, 0)
        let action1 = store.stateChanges[0].action as! AnonymousAction<Void>
        XCTAssertTrue(action1.wasCreated(from: doubleUpCounter))
        let action2 = store.stateChanges[1].action as! AnonymousAction<Void>
        XCTAssertTrue(action2.wasCreated(from: clearCounter))
    }

    func testBindingWithEnableDisable() {
        let lockView = LockView(locked: store.binding(get: lockedSelector, enable: lock, disable: unlock))
        XCTAssertEqual(lockView.locked, false)
        lockView.locked = true
        XCTAssertEqual(lockView.locked, true)
        lockView.locked = false
        XCTAssertEqual(lockView.locked, false)
        let action1 = store.stateChanges[0].action as! AnonymousAction<Void>
        XCTAssertTrue(action1.wasCreated(from: lock))
        let action2 = store.stateChanges[1].action as! AnonymousAction<Void>
        XCTAssertTrue(action2.wasCreated(from: unlock))
    }

    func testBindingWithBoolUpdateValue() {
        let lightsView = LightsView(lightsOn: store.binding(get: lightsOnSelector, send: changeLights))
        XCTAssertEqual(lightsView.lightsOn, false)
        lightsView.lightsOn = true
        XCTAssertEqual(lightsView.lightsOn, true)
        lightsView.lightsOn = false
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
    @Binding public var counter: Int
    var body: some View { Text("Counter: \(counter)") }
}

private struct LockView: View {
    @Binding public var locked: Bool
    var body: some View { Text(locked ? "Locked" : "Unlocked") }
}

private struct LightsView: View {
    @Binding public var lightsOn: Bool
    var body: some View { Text(lightsOn ? "On" : "Off") }
}

private struct TestState {
    var counter: Int = 42
    var locked: Bool = false
    var lightsOn: Bool = false
}
