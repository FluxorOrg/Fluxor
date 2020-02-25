import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ActionTests.allTests),
        testCase(MockStoreTests.allTests),
        testCase(SelectorTests.allTests),
        testCase(StoreTests.allTests),
        testCase(PrintInterceptorTests.allTests),
        testCase(TestInterceptorTests.allTests),
        testCase(ActionPublisherOfTypeTests.allTests),
        testCase(ActionPublisherWasCreatedByTests.allTests),
        testCase(ActionPublisherWithIdentifierTests.allTests)
    ]
}
#endif
