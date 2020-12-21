import Foundation

struct GoogleAnalyticsQueryParamRemover: QueryParamRemover {
    func shouldRemove(queryItem: URLQueryItem, from components: URLComponents) -> Bool {
        return queryItem.name.starts(with: "utm_")
    }
}
