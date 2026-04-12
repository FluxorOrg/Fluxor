import Fluxor
import FluxorTestSupport
import XCTest

@MainActor
final class TestSupportTests: XCTestCase {
    func testMockStoreOverridesSelector() async {
        let store = MockStore(initialState: AppState(), reducers: [
            Reducer(
                ReduceOn(SetName.self) { state, action in
                    state.name = action.name
                }
            )
        ])
        let selector = Selector<AppState, String>(\.name)

        store.overrideSelector(selector, value: "override")

        XCTAssertEqual(store.current(selector), "override")
        var iterator = store.select(selector).makeAsyncIterator()
        let firstValue = await iterator.next()
        XCTAssertEqual(firstValue, "override")
    }

    func testEffectRunnerCapturesDispatchedActions() async throws {
        let effect = Effect<AppState, Void>.on(StartLoading.self) { _, context in
            context.send(SetName(name: "loaded"))
        }

        let actions = try await EffectRunner.run(
            effect,
            with: StartLoading(),
            initialState: AppState()
        )

        XCTAssertEqual(actions.count, 1)
        XCTAssertEqual((actions[0] as? SetName)?.name, "loaded")
    }
}

private struct AppState: Equatable, Sendable {
    var name = ""
}

private struct StartLoading: Action {}

private struct SetName: Action {
    let name: String
}
