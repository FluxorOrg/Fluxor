import AppKit
import Dispatch
import Fluxor
import FluxorSwiftUI
import SwiftUI
import XCTest

@MainActor
final class FluxorProjectionTests: XCTestCase {
    func testProjectionWrapperCreatesFocusedObservableProjection() async throws {
        let store = makeStore()
        let rendered = expectation(description: "Rendered projection")
        var capturedProjection: StoreProjection<AppState, Void, String>?

        let hostingView = NSHostingView(
            rootView: ProjectionCaptureView { projection in
                guard capturedProjection == nil else { return }
                capturedProjection = projection
                rendered.fulfill()
            }
            .environment(store)
        )

        _ = hostingView.fittingSize
        await fulfillment(of: [rendered], timeout: 1)

        let projection = try XCTUnwrap(capturedProjection)
        projection.value = "Updated by Projection"
        XCTAssertEqual(store.state.name, "Updated by Projection")

        store.send(SetName(name: "Updated by Store"))
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(projection.value, "Updated by Store")
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

private struct ProjectionCaptureView: View {
    @FluxorProjection<AppState, Void, String>(Selectors.name, send: { SetName(name: $0) })
    private var nameProjection: StoreProjection<AppState, Void, String>

    let onRender: @MainActor (StoreProjection<AppState, Void, String>) -> Void

    init(onRender: @escaping @MainActor (StoreProjection<AppState, Void, String>) -> Void) {
        self.onRender = onRender
    }

    var body: some View {
        let projection = nameProjection

        DispatchQueue.main.async {
            onRender(projection)
        }

        return Color.clear
            .frame(width: 1, height: 1)
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
