import XCTest

import untrackTests

var tests = [XCTestCaseEntry]()
tests += untrackTests.allTests()
XCTMain(tests)
