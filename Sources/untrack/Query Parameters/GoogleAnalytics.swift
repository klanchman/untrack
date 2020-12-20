import Foundation

struct GoogleAnalyticsQueryParamRemover: QueryParamRemover {
    func shouldRemove(queryItem: URLQueryItem, from url: URL) -> Bool {
        return queryItem.name.starts(with: "utm_")
    }
}
