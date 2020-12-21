import Foundation

struct ACLUQueryParamRemover: QueryParamRemover {
    private static let paramNamesToRemove = [
        "initms_aff",
        "initms_chan",
        "initms",
        "af",
        "gs",
        "ms_aff",
        "ms_chan",
        "ms",
    ]

    func shouldRemove(queryItem: URLQueryItem, from components: URLComponents) -> Bool {
        guard let host = components.host, host.hasSuffix("aclu.org") else { return false }
        return Self.paramNamesToRemove.contains(queryItem.name)
    }
}
