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

struct Logger {
    let level: LogLevel

    /// Logs message to stdout.
    ///
    /// The message is logged regardless of the logger's log level.
    ///
    /// - Parameter message: the message to log
    func output(_ message: Message) {
        print(message)
    }

    /// Logs an error message to stderr.
    ///
    /// The message is logged only when the log level is `.error` or higher.
    ///
    /// - Parameter message: the message to log
    func error(_ message: Message) {
        if level < .error { return }
        var os = PrintOutputStream.stderr
        print(message, to: &os)
    }

    /// Logs a warning message to stderr.
    ///
    /// The message is logged only when the log level is `.warn` or higher.
    ///
    /// - Parameter message: the message to log
    func warn(_ message: Message) {
        if level < .warn { return }
        var os = PrintOutputStream.stderr
        print(message, to: &os)
    }

    /// Logs an info message to stderr.
    ///
    /// The message is logged only when the log level is `.info` or higher.
    ///
    /// - Parameter message: the message to log
    func info(_ message: Message) {
        if level < .info { return }
        var os = PrintOutputStream.stderr
        print(message, to: &os)
    }

    /// Logs a debug message to stderr.
    ///
    /// The message is logged only when the log level is `.debug` or higher.
    ///
    /// - Parameter message: the message to log
    func debug(_ message: Message) {
        if level < .debug { return }
        var os = PrintOutputStream.stderr
        print(message, to: &os)
    }
}

extension Logger {
    enum LogLevel: Int, Comparable {
        case quiet
        case error
        case warn
        case info
        case debug

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// `Logger.Message` represents a log message's text. It is usually created using string literals.
    ///
    /// Example creating a `Logger.Message`:
    ///
    ///     let world: String = "world"
    ///     let myLogMessage: Logger.Message = "Hello \(world)"
    ///
    /// Most commonly, `Logger.Message`s appear simply as the parameter to a logging method such as:
    ///
    ///     logger.info("Hello \(world)")
    ///
    /// Source: https://github.com/apple/swift-log/blob/974b90e00838f81741da77411f822d24fdba1120/Sources/Logging/Logging.swift#L473
    struct Message: ExpressibleByStringLiteral, Equatable, CustomStringConvertible, ExpressibleByStringInterpolation {
        public typealias StringLiteralType = String

        private var value: String

        public init(stringLiteral value: String) {
            self.value = value
        }

        public var description: String {
            return self.value
        }
    }
}

struct PrintOutputStream: TextOutputStream {
    let handle: FileHandle

    init(handle: FileHandle) {
        self.handle = handle
    }

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        handle.write(data)
    }
}

extension PrintOutputStream {
    static let stderr = Self.init(handle: .standardError)
}
