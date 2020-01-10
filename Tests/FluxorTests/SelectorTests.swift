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
                                  birthday: BirthdayState(year: 1960,
                                                          month: "November",
                                                          day: 1),
                                  address: AddressState(address: "One Apple Park Way",
                                                        city: "Cupertino",
                                                        country: "USA"))
    private let nameSelector = createRootSelector(keyPath: \TestState.name)
    private let birthdaySelector = createRootSelector(keyPath: \TestState.birthday)
    private let addressSelector = createRootSelector(keyPath: \TestState.address)

    private lazy var fullNameSelector = createSelector(nameSelector) {
        "\($0.firstName) \($0.lastName)"
    }

    private lazy var formattedBirthdaySelector = createSelector(birthdaySelector) {
        "\($0.month) \($0.day), \($0.year)"
    }

    private lazy var formattedAddressSelector = createSelector(addressSelector) {
        "\($0.address), \($0.city), \($0.country)"
    }

    func testCreateRootSelector() {
        XCTAssertEqual(nameSelector.map(state), state.name)
        XCTAssertEqual(birthdaySelector.map(state), state.birthday)
        XCTAssertEqual(addressSelector.map(state), state.address)
    }

    func testCreateSelector1() {
        XCTAssertEqual(fullNameSelector.map(state), "Tim Cook")
        let name = NameState(firstName: "Steve", lastName: "Jobs")
        XCTAssertEqual(fullNameSelector.projector(name), "Steve Jobs")
    }

    func testCreateSelector2() {
        let congratulationsSelector = createSelector(fullNameSelector, birthdaySelector) {
            fullName, birthday in
            "Congratulations \(fullName)! Today is \(birthday.month) \(birthday.day) - your birthday!"
        }
        XCTAssertEqual(congratulationsSelector.map(state),
                       "Congratulations Tim Cook! Today is November 1 - your birthday!")
        let birthday = BirthdayState(year: 1955, month: "February", day: 24)
        XCTAssertEqual(congratulationsSelector.projector("Steve Jobs", birthday),
                       "Congratulations Steve Jobs! Today is February 24 - your birthday!")
    }

    func testCreateSelector3() {
        let bioSelector = createSelector(fullNameSelector, formattedBirthdaySelector, formattedAddressSelector) {
            fullName, formattedBirthday, formattedAddress in
            """
            Full name: \(fullName)
            Birthday: \(formattedBirthday)
            Work address: \(formattedAddress)
            """
        }
        XCTAssertEqual(bioSelector.map(state), """
        Full name: Tim Cook
        Birthday: November 1, 1960
        Work address: One Apple Park Way, Cupertino, USA
        """)
        XCTAssertEqual(bioSelector.projector("Steve Jobs", "February 24, 1955", "One Infinite Loop, Cupertino, USA"), """
        Full name: Steve Jobs
        Birthday: February 24, 1955
        Work address: One Infinite Loop, Cupertino, USA
        """)
    }
}

private struct TestState: Equatable {
    let name: NameState
    let birthday: BirthdayState
    let address: AddressState
}

private struct NameState: Equatable {
    let firstName: String
    let lastName: String
}

private struct BirthdayState: Equatable {
    let year: Int
    let month: String
    let day: Int
}

private struct AddressState: Equatable {
    let address: String
    let city: String
    let country: String
}
