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

final class MandrillReverserTests: XCTestCase {
    let rev = MandrillReverser()
    let logger = Logger(level: .quiet)
    let components = URLComponents(
        url: URL(
            string:
                "https://mandrillapp.com/track/click/12345/example.com?p=eyJ2IjoxLCJwIjoie1widXJsXCI6XCJodHRwOlxcXC9cXFwvZXhhbXBsZS5jb21cIn0ifQo="
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
