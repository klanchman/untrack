import Foundation

struct TwitterQueryParamRemover: QueryParamRemover {
    func shouldRemove(queryItem: URLQueryItem, from url: URL) -> Bool {
        return url.host == "twitter.com" && queryItem.name == "s"
    }
}
