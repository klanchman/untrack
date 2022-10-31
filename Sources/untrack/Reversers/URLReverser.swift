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

enum URLReverser {
    private static let reversers: [URLReverserProtocol] = [
        OutlookSafelinksReverser(),
        GoogleRedirectReverser(),
        MandrillReverser(),
    ]

    /// Tries to reverse the given URL components, if possible.
    ///
    /// - Parameters:
    ///   - components: the URLComponents to try to reverse
    ///   - logger: a Logger
    ///
    /// - Returns: URLComponents that have been reversed if applicable
    static func tryReverse(components: URLComponents, logger: Logger) -> URLComponents {
        var reversed = components
        if let reverser = reversers.first(where: { $0.canReverse(components: components, logger: logger) }) {
            logger.info("Identified URL to reverse using \(reverser.self)")
            do {
                reversed = try reverser.reverse(components: components, logger: logger)
            } catch {
                logger.error("Error reversing URL: \(error)")
            }
        } else {
            logger.info("No reverser for URL")
        }

        return reversed
    }
}

protocol URLReverserProtocol {
    /// Checks whether the reverser thinks it can reverse the URL components.
    ///
    /// - Parameter components: the URLComponents to check
    func canReverse(components: URLComponents, logger: Logger) -> Bool

    /// Attempts to reverse the URL components.
    ///
    /// - Parameters:
    ///   - components: the URLComponents to reverse
    ///   - logger: a Logger
    func reverse(components: URLComponents, logger: Logger) throws -> URLComponents
}

enum URLReversalError: Error {
    case invalidURL
    case reversalFailure
}
