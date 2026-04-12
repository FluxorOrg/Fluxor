import Fluxor
import FluxorSwiftUI
import Observation
import XCTest

@MainActor
final class StoreProjectionTests: XCTestCase {
    func testBindingHelperDispatchesActions() {
        let store = makeStore()
        let binding = store.binding(get: Selectors.name) { SetName(name: $0) }

        binding.wrappedValue = "Updated"

        XCTAssertEqual(store.state.name, "Updated")
    }

    func testProjectionTracksStoreAndDispatchesMutations() async throws {
        let store = makeStore()
        let projection = store.scope(Selectors.name) { SetName(name: $0) }

        XCTAssertEqual(projection.value, "")

        projection.value = "A"
        XCTAssertEqual(store.state.name, "A")

        store.send(SetName(name: "B"))
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(projection.value, "B")
    }

    private func makeStore() -> Store<AppState, Void> {
        Store(initialState: .init(), reducers: [
            Reducer(
                ReduceOn(SetName.self) { state, action in
                    state.name = action.name
                }
            )
        ])
    }
}

private struct AppState: Equatable, Sendable {
    var name = ""
}

private enum Selectors {
    static let name = Selector<AppState, String>(\.name)
}

private struct SetName: Action {
    let name: String
}
