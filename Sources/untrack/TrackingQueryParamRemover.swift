import Foundation

enum TrackingQueryParamRemover {
    private static let removers: [QueryParamRemover] = [
        GoogleAnalyticsQueryParamRemover(),
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
                    remover.shouldRemove(queryItem: queryItem)
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
    /// Describes whether the given query item should be removed.
    ///
    /// - Parameter queryItem: the URLQueryItem to check
    func shouldRemove(queryItem: URLQueryItem) -> Bool
}

struct GoogleAnalyticsQueryParamRemover: QueryParamRemover {
    func shouldRemove(queryItem: URLQueryItem) -> Bool {
        return queryItem.name.starts(with: "utm_")
    }
}
