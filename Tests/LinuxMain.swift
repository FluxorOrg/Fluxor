import XCTest
import FluxorTests

var tests = [XCTestCaseEntry]()
tests += ActionTests.allTests()
tests += MockStoreTests.allTests(),
tests += SelectorTests.allTests(),
tests += StoreTests.allTests(),
tests += PrintInterceptorTests.allTests(),
tests += TestInterceptorTests.allTests(),
tests += ActionPublisherOfTypeTests.allTests(),
tests += ActionPublisherWasCreatedByTests.allTests(),
tests += ActionPublisherWithIdentifierTests.allTests(),
XCTMain(tests)
