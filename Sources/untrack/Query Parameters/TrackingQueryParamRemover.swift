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
    static func removeTrackingParameters(from url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        if var queryItems = components.queryItems {
            queryItems.removeAll(where: { queryItem in
                Self.removers.contains { remover in
                    remover.shouldRemove(queryItem: queryItem, from: url)
                }
            })

            components.queryItems = queryItems.isEmpty ? nil : queryItems
        }

        guard let cleanURL = components.url else {
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
