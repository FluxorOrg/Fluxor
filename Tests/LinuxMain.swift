import XCTest
import AnyCodableTests
import FluxorTests

var tests = [XCTestCaseEntry]()
tests += AnyCodableEncodingTests.allTests()
tests += AnyCodableEquatableTests.allTests()
tests += AnyCodableStringTests.allTests()
tests += PrintInterceptorTests.allTests()
tests += TestInterceptorTests.allTests()
tests += ActionPublisherOfTypeTests.allTests()
tests += ActionPublisherWasCreatedByTests.allTests()
tests += ActionPublisherWithIdentifierTests.allTests()
tests += ActionTests.allTests()
tests += EffectsTests.allTests()
tests += MockStoreTests.allTests()
tests += ReducerTests.allTests()
tests += SelectorTests.allTests()
tests += StoreTests.allTests()
XCTMain(tests)
