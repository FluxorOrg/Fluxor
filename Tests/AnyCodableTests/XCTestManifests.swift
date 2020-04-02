import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyCodableEncodingTests.allTests),
        testCase(AnyCodableEquatableTests.allTests),
        testCase(AnyCodableStringTests.allTests),
    ]
}
#endif
