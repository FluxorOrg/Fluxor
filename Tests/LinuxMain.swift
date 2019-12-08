import XCTest

import FluxorTests

var tests = [XCTestCaseEntry]()
tests += ActionTests.allTests()
tests += PublisherOfTypeTests.allTests()
tests += StoreInterceptorTests.allTests()
tests += StoreTests.allTests()
XCTMain(tests)
