/**
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

class SelectorTests: XCTestCase {
    private var state = TestState(name: NameState(firstName: "Tim",
                                                  lastName: "Cook"),
                                  birthday: BirthdayState(year: 1960,
                                                          month: "November",
                                                          day: 1),
                                  address: AddressState(address: "One Apple Park Way",
                                                        city: "Cupertino",
                                                        country: "USA"),
                                  scandals: ScandalsState(iphone: "Bendgate",
                                                          other: "Apple Maps launch"),
                                  newProducts: NewProductState(products: [
                                      "Watch", "HomePod", "AirPods"
                                  ]))
    private let nameSelector = createRootSelector(keyPath: \TestState.name)
    private let birthdaySelector = createRootSelector(keyPath: \TestState.birthday)
    private let addressSelector = createRootSelector(keyPath: \TestState.address)
    private let scandalsSelector = createRootSelector(keyPath: \TestState.scandals)
    private let newProductsSelector = createRootSelector(keyPath: \TestState.newProducts)

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
        let newestProductSelector = createSelector(newProductsSelector) {
            $0.products.last!
        }
        let productLaunchSelector = createSelector(fullNameSelector, newestProductSelector, formattedAddressSelector) {
            fullName, newestProduct, formattedAddress in
            "Yesterday \(fullName) presented the newest \(newestProduct) at a Town Hall Meeting at Apple (\(formattedAddress))"
        }

        XCTAssertEqual(productLaunchSelector.map(state), "Yesterday Tim Cook presented the newest AirPods at a Town Hall Meeting at Apple (One Apple Park Way, Cupertino, USA)")
        XCTAssertEqual(productLaunchSelector.projector("Steve Jobs", "iPad", "One Infinite Loop, Cupertino, USA"),
                       "Yesterday Steve Jobs presented the newest iPad at a Town Hall Meeting at Apple (One Infinite Loop, Cupertino, USA)")
    }

    func testCreateSelector4() {
        let iphoneScandalSelector = createSelector(scandalsSelector) {
            $0.iphone
        }
        let scandalMeetingSelector = createSelector(fullNameSelector, formattedBirthdaySelector, formattedAddressSelector, iphoneScandalSelector) {
            fullName, formattedBirthday, formattedAddress, iphoneScandal in
            "Today \(fullName) (born \(formattedBirthday)) held a Town Hall Meeting at Apple (\(formattedAddress)) about \(iphoneScandal)"
        }

        XCTAssertEqual(scandalMeetingSelector.map(state), "Today Tim Cook (born November 1, 1960) held a Town Hall Meeting at Apple (One Apple Park Way, Cupertino, USA) about Bendgate")
        XCTAssertEqual(scandalMeetingSelector.projector("Steve Jobs", "February 24, 1955", "One Infinite Loop, Cupertino, USA", "Antennagate"),
                       "Today Steve Jobs (born February 24, 1955) held a Town Hall Meeting at Apple (One Infinite Loop, Cupertino, USA) about Antennagate")
    }

    func testCreateSelector5() {
        let bioSelector = createSelector(fullNameSelector, formattedBirthdaySelector, formattedAddressSelector, scandalsSelector, newProductsSelector) {
            fullName, formattedBirthday, formattedAddress, scandals, newProducts in
            """
            Full name: \(fullName)
            Birthday: \(formattedBirthday)
            Work address: \(formattedAddress)
            Scandals: \(scandals.iphone) and \(scandals.other)
            New products: \(newProducts.products.joined(separator: ", "))
            """
        }
        XCTAssertEqual(bioSelector.map(state), """
        Full name: Tim Cook
        Birthday: November 1, 1960
        Work address: One Apple Park Way, Cupertino, USA
        Scandals: Bendgate and Apple Maps launch
        New products: Watch, HomePod, AirPods
        """)
        XCTAssertEqual(bioSelector.projector("Steve Jobs", "February 24, 1955", "One Infinite Loop, Cupertino, USA",
                                             ScandalsState(iphone: "Antennagate", other: "Lost iPhone 4 prototype"),
                                             NewProductState(products: ["Mac", "iPod", "iPhone", "iPad"])), """
            Full name: Steve Jobs
            Birthday: February 24, 1955
            Work address: One Infinite Loop, Cupertino, USA
            Scandals: Antennagate and Lost iPhone 4 prototype
            New products: Mac, iPod, iPhone, iPad
            """)
    }

    func testMemoizedSelectorMapSetsResult() {
        // Given
        let initialStateHash = UUID()
        let selector = fullNameSelector
        XCTAssertNil(selector.result)
        // When
        XCTAssertEqual(selector.map(state, stateHash: initialStateHash), "Tim Cook")
        // Then
        XCTAssertEqual(selector.result?.value, "Tim Cook")
        XCTAssertEqual(selector.result?.stateHash, initialStateHash)

        // When
        state.name = NameState(firstName: "Steve", lastName: "Jobs")
        XCTAssertEqual(selector.map(state, stateHash: initialStateHash), "Tim Cook")
        // Then
        XCTAssertEqual(selector.result?.value, "Tim Cook")
        XCTAssertEqual(selector.result?.stateHash, initialStateHash)

        // Given
        let changedStateHash = UUID()
        XCTAssertEqual(selector.map(state, stateHash: changedStateHash), "Steve Jobs")
        // Then
        XCTAssertEqual(selector.result?.value, "Steve Jobs")
        XCTAssertEqual(selector.result?.stateHash, changedStateHash)
    }
    
    func testMemoizedSelectorSetsResult() {
        // Given
        let initialStateHash = UUID()
        let selector = fullNameSelector
        XCTAssertNil(selector.result)
        selector.setResult(value: "Phil Schiller")
        // When
        XCTAssertEqual(selector.map(state, stateHash: initialStateHash), "Phil Schiller")
        // Then
        XCTAssertEqual(selector.result?.value, "Phil Schiller")
        XCTAssertEqual(selector.result?.stateHash, nil)
    }
}

private struct TestState: Equatable {
    var name: NameState
    let birthday: BirthdayState
    let address: AddressState
    let scandals: ScandalsState
    let newProducts: NewProductState
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

private struct ScandalsState: Equatable {
    let iphone: String
    let other: String
}

private struct NewProductState: Equatable {
    let products: [String]
}
