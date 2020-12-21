import Foundation

extension Data {
    /// Creates `Data` from a base64url-encoded string (RFC 4648 §5).
    ///
    /// The built-in `init(base64Encoded:options:)` initializer expects a base64 (RFC 4648 §4)
    /// string, whereas this initializer expects a URL-safe base64 string.
    ///
    /// From: https://stackoverflow.com/a/43500088
    ///
    /// - Parameter base64urlString: a base64url string
    init?(base64urlEncoded base64urlString: String) {
        var base64 = base64urlString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }

        self.init(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
