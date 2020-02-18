import XCTest

import FluxorTests

var tests = [XCTestCaseEntry]()
tests += ActionTests.allTests()
tests += PublisherOfTypeTests.allTests()
tests += InterceptorTests.allTests()
tests += StoreTests.allTests()
XCTMain(tests)
