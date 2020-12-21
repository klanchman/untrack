import Foundation

enum URLReverser {
    private static let reversers: [URLReverserProtocol] = [
        ACLUURLReverser(),
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
        if let reverser = reversers.first(where: { $0.canReverse(components: components) }) {
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
    func canReverse(components: URLComponents) -> Bool

    /// Attempts to reverse the URL components.
    ///
    /// - Parameters:
    ///   - components: the URLComponents to reverse
    ///   - logger: a Logger
    func reverse(components: URLComponents, logger: Logger) throws -> URLComponents
}
