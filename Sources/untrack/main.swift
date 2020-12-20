import ArgumentParser
import Foundation

struct Untrack: ParsableCommand {
    @Argument(help: "The URL from which to remove trackers.", transform: Self.convertStringToURL)
    var url: URL

    @Flag(name: .shortAndLong, help: .hidden)
    var debug: Bool = false

    @Flag(name: .shortAndLong, help: "Do not show log messages.")
    var quiet: Bool = false

    @Flag(name: .shortAndLong, help: "Show verbose output.")
    var verbose: Bool = false

    func run() throws {
        let logger = Logger(level: resolvedLogLevel)
        let result = TrackingQueryParamRemover.removeTrackingParameters(from: url, logger: logger)
        logger.output("\(result.absoluteString)")
    }
}

extension Untrack {
    private static func convertStringToURL(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw Error.parseError
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
        case parseError
    }
}

Untrack.main()
