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

import Foundation

/// Reverses URLs redirected through Mandrill.
///
/// URLs have the following format:
/// https://mandrillapp.com/track/click/:someID/:destinationHostname?p=:base64JSONBlob
///
/// When decoded, `base64JSONBlob` has this format (only relevant items included):
/// ```json
/// {
///   "p": "{\"url\":\"destinationURL\"}"
/// }
/// ```
/// In other words, `p` is a JSON string that contains a `url` property that is the destination URL.
///
/// The destination URL could need untracking of its own.
struct MandrillReverser: URLReverserProtocol {
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
        return (components.host ?? "").hasSuffix("mandrillapp.com")
            && components.path.starts(with: "/track/click")
    }

    private func getDestinationURL(from components: URLComponents, logger: Logger) -> String? {
        guard
            let base64Blob = components.queryItems?.first(where: { $0.name == "p" })?.value,
            let jsonBlob = Data(base64urlEncoded: base64Blob)
        else {
            logger.warn("Mandrill: Could not extract JSON blob or convert it to Data")
            return nil
        }

        do {
            return try JSONDecoder().decode(JSONBlob.self, from: jsonBlob).p.url
        } catch {
            logger.warn("Mandrill: Error decoding JSON: \(error)")
            return nil
        }
    }
}

private extension MandrillReverser {
    struct JSONBlob: Decodable {
        let p: Payload

        enum CodingKeys: String, CodingKey {
            case p
        }

        init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let subDecoder = JSONDecoder()
            let rawP = try container.decode(String.self, forKey: .p)
            guard let pData = rawP.data(using: .utf8) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .p,
                    in: container,
                    debugDescription: "Could not convert 'p' to Data"
                )
            }

            p = try subDecoder.decode(Payload.self, from: pData)
        }

        struct Payload: Decodable {
            let url: String
        }
    }
}
