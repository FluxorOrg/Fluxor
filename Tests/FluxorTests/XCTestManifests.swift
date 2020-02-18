import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ActionTests.allTests),
        testCase(PublisherOfTypeTests.allTests),
        testCase(InterceptorTests.allTests),
        testCase(StoreTests.allTests),
    ]
}
#endif
