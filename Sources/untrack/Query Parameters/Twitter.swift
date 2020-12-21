import Foundation

struct TwitterQueryParamRemover: QueryParamRemover {
    func shouldRemove(queryItem: URLQueryItem, from components: URLComponents) -> Bool {
        return components.host == "twitter.com" && queryItem.name == "s"
    }
}
