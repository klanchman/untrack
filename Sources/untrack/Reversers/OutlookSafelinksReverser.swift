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

/// Reverses URLs "protected" by Outlook Safe Links.
///
/// URLs have the following format:
/// https://:maybeDatacenterName.safelinks.protection.outlook.com/?url=:destinationURL&...
///
/// The destination URL could need untracking of its own.
struct OutlookSafelinksReverser: URLReverserProtocol {
    private static let expectedHostEndsWith = "safelinks.protection.outlook.com"
    private static let destinationURLQueryParamName = "url"

    func canReverse(components: URLComponents) -> Bool {
        return validate(components: components)
    }

    func reverse(components: URLComponents, logger: Logger) throws -> URLComponents {
        guard
            validate(components: components),
            let destinationURL = getDestinationURL(from: components),
            !destinationURL.isEmpty
        else {
            throw URLReversalError.invalidURL
        }

        logger.debug("Destination URL: \(destinationURL)")

        guard let destinationComponents = URLComponents(string: destinationURL) else {
            throw URLReversalError.reversalFailure
        }

        return destinationComponents
    }

    private func validate(components: URLComponents) -> Bool {
        return (components.host ?? "").hasSuffix(Self.expectedHostEndsWith)
            && getDestinationURL(from: components)?.isEmpty == false
    }

    private func getDestinationURL(from components: URLComponents) -> String? {
        components.queryItems?.first(where: { $0.name == Self.destinationURLQueryParamName })?.value
    }
}
