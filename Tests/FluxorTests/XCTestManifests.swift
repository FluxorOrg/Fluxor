import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PrintInterceptorTests.allTests),
        testCase(TestInterceptorTests.allTests),

        testCase(ActionPublisherOfTypeTests.allTests),
        testCase(ActionPublisherWasCreatedByTests.allTests),
        testCase(ActionPublisherWithIdentifierTests.allTests),

        testCase(ActionTests.allTests),
        testCase(EffectsTests.allTests),
        testCase(MockStoreTests.allTests),
        testCase(ReducerTests.allTests),
        testCase(SelectorTests.allTests),
        testCase(StoreTests.allTests)
    ]
}
#endif
