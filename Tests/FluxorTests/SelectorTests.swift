/*
 * FluxorTests
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

@testable import Fluxor
import XCTest

// swiftlint:disable closure_parameter_position line_length

struct Person {
    let name: String
}

class SelectorTests: XCTestCase {
    private var state: TestState!
    private let nameSelector = Selector(keyPath: \TestState.name)
    private let birthdaySelector = Selector(keyPath: \TestState.birthday)
    private let addressSelector = Selector(keyPath: \TestState.address)
    private let scandalsSelector = Selector(keyPath: \TestState.scandals)
    private let newProductsSelector = Selector(projector: { (state: TestState) in state.newProducts })

    private lazy var fullNameSelector = Selector.with(nameSelector) {
        "\($0.firstName) \($0.lastName)"
    }

    private lazy var firstNameSelector = Selector.with(nameSelector, keyPath: \.firstName)

    private lazy var formattedBirthdaySelector = Selector.with(birthdaySelector) {
        "\($0.month) \($0.day), \($0.year)"
    }

    private lazy var formattedAddressSelector = Selector.with(addressSelector) {
        "\($0.address), \($0.city), \($0.country)"
    }

    override func setUp() {
        super.setUp()
        state = TestState(name: NameState(firstName: "Tim",
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
                              "Watch", "HomePod", "AirPods",
                          ]))
    }

    private func modifyState() {
        state.name = NameState(firstName: "Steve", lastName: "Jobs")
        state.birthday = BirthdayState(year: 1955, month: "February", day: 24)
        state.address = AddressState(address: "One Infinite Loop", city: "Cupertino", country: "USA")
        state.scandals = ScandalsState(iphone: "Antennagate", other: "Lost iPhone 4 prototype")
        state.newProducts = NewProductState(products: ["Mac", "iPod", "iPhone", "iPad"])
    }

    /// Is it possible to create a `Selector` with no `Selector`s and map the state?
    func testCreateSelector() {
        XCTAssertEqual(nameSelector.map(state), state.name)
        XCTAssertEqual(birthdaySelector.map(state), state.birthday)
        XCTAssertEqual(addressSelector.map(state), state.address)
    }

    /// Is it possible to create a `Selector` with 1 `Selector`s and map the state with projector?
    func testCreateSelector1_Projector() {
        XCTAssertEqual(fullNameSelector.map(state), "Tim Cook")
        modifyState()
        XCTAssertEqual(fullNameSelector.map(state), "Steve Jobs")
    }

    /// Is it possible to create a `Selector` with 1 `Selector`s and map the state with KeyPath?
    func testCreateSelector1_KeyPath() {
        XCTAssertEqual(firstNameSelector.map(state), "Tim")
        modifyState()
        XCTAssertEqual(firstNameSelector.map(state), "Steve")
    }

    /// Is it possible to create a `Selector` with 2 `Selector`s and map the state?
    func testCreateSelector2() {
        let congratulationsSelector = Selector.with(fullNameSelector, birthdaySelector) {
            fullName, birthday in "Congratulations \(fullName)! Today is \(birthday.month) \(birthday.day) - your birthday!"
        }
        XCTAssertEqual(congratulationsSelector.map(state), "Congratulations Tim Cook! Today is November 1 - your birthday!")
        modifyState()
        XCTAssertEqual(congratulationsSelector.map(state), "Congratulations Steve Jobs! Today is February 24 - your birthday!")
    }

    /// Is it possible to create a `Selector` with 3 `Selector`s and map the state?
    func testCreateSelector3() {
        let newestProductSelector = Selector.with(newProductsSelector) { $0.products.last! }
        let productLaunchSelector = Selector.with(fullNameSelector, newestProductSelector, formattedAddressSelector) {
            fullName, newestProduct, formattedAddress in "Yesterday \(fullName) presented the newest \(newestProduct) at a Town Hall Meeting at Apple (\(formattedAddress))"
        }
        XCTAssertEqual(productLaunchSelector.map(state), "Yesterday Tim Cook presented the newest AirPods at a Town Hall Meeting at Apple (One Apple Park Way, Cupertino, USA)")
        modifyState()
        XCTAssertEqual(productLaunchSelector.map(state), "Yesterday Steve Jobs presented the newest iPad at a Town Hall Meeting at Apple (One Infinite Loop, Cupertino, USA)")
    }

    /// Is it possible to create a `Selector` with 4 `Selector`s and map the state?
    func testCreateSelector4() {
        let iphoneScandalSelector = Selector.with(scandalsSelector) { $0.iphone }
        let scandalMeetingSelector = Selector.with(fullNameSelector, formattedBirthdaySelector, formattedAddressSelector, iphoneScandalSelector) {
            fullName, formattedBirthday, formattedAddress, iphoneScandal in "Today \(fullName) (born \(formattedBirthday)) held a Town Hall Meeting at Apple (\(formattedAddress)) about \(iphoneScandal)"
        }

        XCTAssertEqual(scandalMeetingSelector.map(state), "Today Tim Cook (born November 1, 1960) held a Town Hall Meeting at Apple (One Apple Park Way, Cupertino, USA) about Bendgate")
        modifyState()
        XCTAssertEqual(scandalMeetingSelector.map(state), "Today Steve Jobs (born February 24, 1955) held a Town Hall Meeting at Apple (One Infinite Loop, Cupertino, USA) about Antennagate")
    }

    /// Is it possible to create a `Selector` with 5 `Selector`s and map the state?
    func testCreateSelector5() {
        let bioSelector = Selector.with(fullNameSelector, formattedBirthdaySelector, formattedAddressSelector, scandalsSelector, newProductsSelector) {
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
        modifyState()
        XCTAssertEqual(bioSelector.map(state), """
        Full name: Steve Jobs
        Birthday: February 24, 1955
        Work address: One Infinite Loop, Cupertino, USA
        Scandals: Antennagate and Lost iPhone 4 prototype
        New products: Mac, iPod, iPhone, iPad
        """)
    }

    /// Does the selector cache its result?
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

    private struct TestState: Equatable {
        var name: NameState
        var birthday: BirthdayState
        var address: AddressState
        var scandals: ScandalsState
        var newProducts: NewProductState
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
}
