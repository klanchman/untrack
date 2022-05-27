/*
 Copyright 2020 Kyle Lanchman

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

enum TrackingQueryParamRemover {
    private static let removers: [QueryParamRemover] = [
        GoogleAnalyticsQueryParamRemover(),
        TwitterQueryParamRemover(),
    ]

    /// Removes query parameters from the given URL components that are known to be used for tracking.
    ///
    /// - Parameters:
    ///   - components: the URLComponents to remove known tracking parameters from
    ///   - logger: a Logger
    ///
    /// - Returns: URLComponents with known tracking parameters removed
    static func removeTrackingParameters(from components: URLComponents, logger: Logger) -> URLComponents {
        var newComponents = components

        if var queryItems = newComponents.queryItems {
            queryItems.removeAll(where: { queryItem in
                logger.debug("Checking query item \(queryItem)")
                return Self.removers.contains { remover in
                    let shouldRemove = remover.shouldRemove(queryItem: queryItem, from: components)
                    logger.debug("Remover \(remover.self) should remove? \(shouldRemove)")
                    return shouldRemove
                }
            })

            newComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        } else {
            logger.info("URL has no query parameters")
        }

        return newComponents
    }
}

protocol QueryParamRemover {
    /// Describes whether the given query item should be removed from the URL.
    ///
    /// - Parameter queryItem: the URLQueryItem to check
    /// - Parameter components: the URLComponents the query item appears in
    func shouldRemove(queryItem: URLQueryItem, from components: URLComponents) -> Bool
}
