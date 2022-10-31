/*
 Copyright 2022 Kyle Lanchman

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest

import class Foundation.Bundle

@testable import untrack

final class OutlookSafelinksReverserTests: XCTestCase {
    let rev = OutlookSafelinksReverser()
    let logger = Logger(level: .quiet)
    let components = URLComponents(
        url: URL(
            string: "https://nam02.safelinks.protection.outlook.com/?url=http%3A%2F%2Fexample.com"
        )!,
        resolvingAgainstBaseURL: false
    )!

    func test_canReverse_returnsTrueForValidURL() throws {
        XCTAssertTrue(rev.canReverse(components: components, logger: logger))
    }

    func test_reverser_reversesValidURL() throws {
        let reversed = try rev.reverse(components: components, logger: logger)

        XCTAssertEqual(
            reversed,
            URLComponents(url: URL(string: "http://example.com")!, resolvingAgainstBaseURL: false)
        )
    }
}
