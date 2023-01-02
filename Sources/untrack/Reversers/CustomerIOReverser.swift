/*
 Copyright 2023 Kyle Lanchman

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

/// Reverses URLs redirected through Customer.io.
///
/// URLs have the following format:
/// https://e.customeriomail.com/e/c/:base64JSONBlob/:someID
///
/// When decoded, `base64JSONBlob` has this format (only relevant items included):
/// ```json
/// {
///   "href": "destinationURL"
/// }
/// ```
/// In other words, the JSON blob contains an `href` property that is the destination URL.
///
/// The destination URL could need untracking of its own.
struct CustomerIOReverser: URLReverserProtocol {
    func canReverse(components: URLComponents, logger: Logger) -> Bool {
        return validate(components: components, logger: logger)
    }

    func reverse(components: URLComponents, logger: Logger) throws -> URLComponents {
        guard
            validate(components: components, logger: logger),
            let destinationURL = getDestinationURL(from: components, logger: logger),
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

    private func validate(components: URLComponents, logger: Logger) -> Bool {
        return (components.host ?? "").hasSuffix("customeriomail.com")
            && components.path.starts(with: "/e/c")
    }

    private func getDestinationURL(from components: URLComponents, logger: Logger) -> String? {
        let pathComponents = components.path
            .components(separatedBy: "/")
            .compactMap { $0.isEmpty ? nil : $0 }

        guard pathComponents.count >= 3 else {
            logger.warn("CustomerIO: Unexpected number of path components: \(pathComponents.count)")
            return nil
        }

        guard let jsonBlob = Data(base64urlEncoded: pathComponents[2]) else {
            logger.warn("CustomerIO: Could not extract JSON blob or convert it to Data")
            return nil
        }

        do {
            return try JSONDecoder().decode(JSONBlob.self, from: jsonBlob).href
        } catch {
            logger.warn("CustomerIO: Error decoding JSON: \(error)")
            return nil
        }
    }
}

private extension CustomerIOReverser {
    struct JSONBlob: Decodable {
        let href: String
    }
}
