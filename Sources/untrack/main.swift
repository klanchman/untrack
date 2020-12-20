import ArgumentParser
import Foundation

struct Untrack: ParsableCommand {
    @Argument(help: "The URL from which to remove trackers.", transform: Self.convertStringToURL)
    var url: URL

    func run() throws {
        print(TrackingQueryParamRemover.removeTrackingParameters(from: url))
    }
}

extension Untrack {
    private static func convertStringToURL(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw Error.parseError
        }

        return url
    }

    enum Error: Swift.Error {
        case parseError
    }
}

Untrack.main()
