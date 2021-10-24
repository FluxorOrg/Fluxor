/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

@testable import Fluxor
import XCTest

final class StorePropertyWrapperTests: XCTestCase {
    func testAddStore() throws {
        let store = Store(initialState: TestState(counter: 42))
        StorePropertyWrapper.addStore(store)
        let savedStore: AnyEnvironmentStore<TestState> = try StorePropertyWrapper.getStore()
        XCTAssertEqual(savedStore.selectCurrent(Selector(keyPath: \TestState.counter)), 42)
    }

    func testStoreNotAdded() throws {
        let store = Store(initialState: TestState(counter: 42))
        StorePropertyWrapper.addStore(store)
        XCTAssertThrowsError(try StorePropertyWrapper.getStore() as AnyEnvironmentStore<String>) { error in
            // swiftlint:disable:next force_cast
            XCTAssertEqual(error as! StorePropertyWrapperError, .storeNotFound(stateName: "String"))
        }
    }
}

extension StorePropertyWrapperError: Equatable {
    public static func == (lhs: StorePropertyWrapperError, rhs: StorePropertyWrapperError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

private struct TestState: Encodable {
    let counter: Int
}

#endif
