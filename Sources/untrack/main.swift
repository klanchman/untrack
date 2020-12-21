import ArgumentParser
import Foundation

struct Untrack: ParsableCommand {
    @Argument(help: "The URL from which to remove trackers.", transform: Self.convertStringToURLComponents)
    var url: URLComponents

    @Flag(name: .shortAndLong, help: .hidden)
    var debug: Bool = false

    @Flag(name: .shortAndLong, help: "Do not show log messages.")
    var quiet: Bool = false

    @Flag(name: .shortAndLong, help: "Show verbose output.")
    var verbose: Bool = false

    func run() throws {
        let logger = Logger(level: resolvedLogLevel)

        let reversed = URLReverser.tryReverse(components: url, logger: logger)
        let result =
            TrackingQueryParamRemover.removeTrackingParameters(from: reversed, logger: logger)

        guard let finalURL = result.url else {
            Self.exit(withError: Error.conversionError)
        }

        logger.output("\(finalURL.absoluteString)")
    }
}

extension Untrack {
    private static func convertStringToURLComponents(_ string: String) throws -> URLComponents {
        guard let url = URLComponents(string: string) else {
            throw Error.parseError
        }

        guard url.scheme == "http" || url.scheme == "https" else {
            throw Error.unsupportedURLScheme
        }

        guard let host = url.host, !host.isEmpty else {
            throw Error.missingHostname
        }

        return url
    }

    private var resolvedLogLevel: Logger.LogLevel {
        switch (debug, verbose, quiet) {
        case (true, _, _): return .debug
        case (_, true, _): return .info
        case (_, _, true): return .quiet
        default: return .warn
        }
    }

    enum Error: Swift.Error {
        case conversionError
        case missingHostname
        case parseError
        case unsupportedURLScheme
    }
}

extension Untrack.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .conversionError:
            return "Could not build the final URL."
        case .missingHostname:
            return "The URL does not have a hostname."
        case .parseError:
            return "The URL could not be parsed."
        case .unsupportedURLScheme:
            return "The URL has an unsupported scheme. (Only `http` and `https` are supported.)"
        }
    }
}

Untrack.main()
