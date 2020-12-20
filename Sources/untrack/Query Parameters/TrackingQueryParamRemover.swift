import Foundation

enum TrackingQueryParamRemover {
    private static let removers: [QueryParamRemover] = [
        GoogleAnalyticsQueryParamRemover(),
        TwitterQueryParamRemover(),
    ]

    /// Removes query parameters from the given URL that are known to be used for tracking.
    ///
    /// - Parameter url: the URL to remove known tracking parameters from
    /// - Returns: a URL with known tracking parameters removed
    static func removeTrackingParameters(from url: URL, logger: Logger) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            logger.warn("Could not resolve components of URL")
            return url
        }

        if var queryItems = components.queryItems {
            queryItems.removeAll(where: { queryItem in
                logger.debug("Checking query item \(queryItem)")
                return Self.removers.contains { remover in
                    let shouldRemove = remover.shouldRemove(queryItem: queryItem, from: url)
                    logger.debug("Remover \(remover.self) should remove? \(shouldRemove)")
                    return shouldRemove
                }
            })

            components.queryItems = queryItems.isEmpty ? nil : queryItems
        } else {
            logger.info("URL has no query parameters")
        }

        guard let cleanURL = components.url else {
            logger.warn("Could not convert URL components into URL")
            return url
        }

        return cleanURL
    }
}

protocol QueryParamRemover {
    /// Describes whether the given query item should be removed from the URL.
    ///
    /// - Parameter queryItem: the URLQueryItem to check
    /// - Parameter url: the URL the query item appears in
    func shouldRemove(queryItem: URLQueryItem, from url: URL) -> Bool
}
