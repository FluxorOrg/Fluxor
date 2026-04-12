import Fluxor
import FluxorTestSupport
import XCTest

@MainActor
final class StoreTests: XCTestCase {
    func testReducerUpdatesCurrentValue() {
        let store = makeStore()

        store.send(Increment(amount: 2))

        XCTAssertEqual(store.current(Selectors.counter), 2)
        XCTAssertEqual(store.state.counter, 2)
    }

    func testSelectEmitsInitialAndUpdatedValues() async {
        let store = makeStore()
        let stream = store.select(Selectors.counter)
        var iterator = stream.makeAsyncIterator()

        let initialValue = await iterator.next()
        store.send(Increment(amount: 3))
        let updatedValue = await iterator.next()

        XCTAssertEqual(initialValue, 0)
        XCTAssertEqual(updatedValue, 3)
    }

    func testEffectDispatchesFollowUpAction() async throws {
        let store = makeStore()
        let interceptor = TestInterceptor<AppState>()
        store.register(interceptor: interceptor)
        store.register(effect: Effect<AppState, Void>.on(LoadRemote.self) { _, context in
            context.send(RemoteLoaded(amount: 5))
        }, id: "remote")

        store.send(LoadRemote())

        try await interceptor.waitForActions(expectedNumberOfActions: 2)
        XCTAssertEqual(store.state.counter, 5)
        XCTAssertTrue(interceptor.stateChanges[0].action is LoadRemote)
        XCTAssertTrue(interceptor.stateChanges[1].action is RemoteLoaded)
    }

    func testUnregisterEffectsCancelsRunningTasks() async throws {
        let store = makeStore()
        let interceptor = TestInterceptor<AppState>()
        store.register(interceptor: interceptor)
        store.register(effect: Effect<AppState, Void>.on(LoadSlowly.self) { _, context in
            try? await Task.sleep(for: .seconds(5))
            guard !context.isCancelled else { return }
            context.send(RemoteLoaded(amount: 99))
        }, id: "slow")

        store.send(LoadSlowly())
        store.unregisterEffects(withId: "slow")
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(interceptor.stateChanges.count, 1)
        XCTAssertEqual(store.state.counter, 0)
    }

    func testMemoizedSelectorOnlyProjectsWhenInputsChange() {
        let projectionCounter = ProjectionCounter()
        let selector = Selector<AppState, String>.combine(Selectors.counter) { value in
            projectionCounter.count += 1
            return "Count: \(value)"
        }
        let store = makeStore()

        XCTAssertEqual(store.current(selector), "Count: 0")
        XCTAssertEqual(store.current(selector), "Count: 0")
        XCTAssertEqual(projectionCounter.count, 1)

        store.send(Increment(amount: 1))

        XCTAssertEqual(store.current(selector), "Count: 1")
        XCTAssertEqual(projectionCounter.count, 2)
    }

    private func makeStore() -> Store<AppState, Void> {
        Store(initialState: .init(), reducers: [
            Reducer(
                ReduceOn(Increment.self) { state, action in
                    state.counter += action.amount
                },
                ReduceOn(RemoteLoaded.self) { state, action in
                    state.counter += action.amount
                }
            )
        ])
    }
}

private final class ProjectionCounter {
    var count = 0
}

private struct AppState: Equatable, Sendable {
    var counter = 0
}

private enum Selectors {
    static let counter = Selector<AppState, Int>(\.counter)
}

private struct Increment: Action {
    let amount: Int
}

private struct LoadRemote: Action {}

private struct LoadSlowly: Action {}

private struct RemoteLoaded: Action {
    let amount: Int
}
