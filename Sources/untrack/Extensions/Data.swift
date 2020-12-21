/*
 Copyright 2020 Kyle Lanchman

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

import Foundation

extension Data {
    /// Creates `Data` from a base64url-encoded string (RFC 4648 §5).
    ///
    /// The built-in `init(base64Encoded:options:)` initializer expects a base64 (RFC 4648 §4)
    /// string, whereas this initializer expects a URL-safe base64 string.
    ///
    /// From: https://stackoverflow.com/a/43500088
    ///
    /// - Parameter base64urlString: a base64url string
    init?(base64urlEncoded base64urlString: String) {
        var base64 = base64urlString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }

        self.init(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
