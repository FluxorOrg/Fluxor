/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

final class StorePropertyWrapperTests: XCTestCase {
    func testAddStore() throws {
        let store = Store(initialState: 42)
        StorePropertyWrapper.addStore(store)
        let savedStore: AnyEnvironmentStore<Int> = try StorePropertyWrapper.getStore()
        XCTAssertEqual(savedStore.selectCurrent(Selector(keyPath: \.self)), 42)
    }

    func testStoreNotAdded() throws {
        let store = Store(initialState: 42)
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
