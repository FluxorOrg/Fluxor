import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyEncodableEncodingTests.allTests),
        testCase(AnyEncodableEquatableTests.allTests),
        testCase(AnyEncodableStringTests.allTests),
    ]
}
#endif
