import Foundation

/// Reverses URLs found in ACLU emails.
///
/// URLs have the following format: https://link.aclu.org/click/:someId/:base64DestinationURL/:someOtherId
///
/// The only part that actually matters if the `base64DestinationURL`. Note that the encoded URL
/// typically _also_ has tracking query parameters.
struct ACLUURLReverser: URLReverserProtocol {
    private static let expectedHost = "link.aclu.org"
    private static let numExpectedPathComponents = 5
    private static let destinationBase64Index = 3

    func canReverse(components: URLComponents) -> Bool {
        return validate(components: components)
    }

    func reverse(components: URLComponents, logger: Logger) throws -> URLComponents {
        guard
            let url = components.url,
            validate(components: components)
        else {
            throw URLReversalError.invalidURL
        }

        let destinationBase64 = url.pathComponents[Self.destinationBase64Index]
        logger.debug("Destination base64: \(destinationBase64)")

        guard let destinationData = Data(base64urlEncoded: destinationBase64) else {
            logger.info("Could not reverse URL: could not convert base64 destination to Data")
            throw URLReversalError.reversalFailure
        }

        guard let rawDestination = String(data: destinationData, encoding: .utf8) else {
            logger.info("Could not reverse URL: could not convert Data to String")
            throw URLReversalError.reversalFailure
        }

        guard let destinationURL = URLComponents(string: rawDestination) else {
            logger.info("Could not reverse URL: could not convert String to URLComponents")
            throw URLReversalError.reversalFailure
        }

        return destinationURL
    }

    private func validate(components: URLComponents) -> Bool {
        return components.host == Self.expectedHost &&
            components.url!.pathComponents.count == Self.numExpectedPathComponents
    }
}
