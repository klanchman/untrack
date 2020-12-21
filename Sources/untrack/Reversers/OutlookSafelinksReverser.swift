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
