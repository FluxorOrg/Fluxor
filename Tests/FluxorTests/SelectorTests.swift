/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Fluxor
import XCTest

class SelectorTests: XCTestCase {
    private let state = TestState(name: NameState(firstName: "Tim",
                                                  lastName: "Cook"),
                                  age: AgeState(years: 59,
                                                months: 3),
                                  address: AddressState(address: "One Apple Park Way,",
                                                        city: "Cupertino",
                                                        country: "USA"))

    func testCreateRootSelector() {
        let nameSelector = createRootSelector(keyPath: \TestState.name)
        XCTAssertEqual(nameSelector.map(state), state.name)
    }
}

private struct TestState: Equatable {
    let name: NameState
    let age: AgeState
    let address: AddressState
}

private struct NameState: Equatable {
    let firstName: String
    let lastName: String
}

private struct AgeState: Equatable {
    let years: Int
    let months: Int
}

private struct AddressState: Equatable {
    let address: String
    let city: String
    let country: String
}
