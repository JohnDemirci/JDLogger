// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog
import SwiftUI

final class LoggerManager {
    /*
     Contains a dictionary of loggers using their identifiers as key.

     Both the key and the logger are weakly held objects. Once they are no longer in use,
     they are automatically removed.
     */
    var loggers: NSMapTable<Identifier<IdentifiableLogger>, IdentifiableLogger>

    private let queue = DispatchQueue(label: "com.jd.logger.queue")
    private let fileWriter = FileLogWriter()

    private init() {
        self.loggers = .weakToWeakObjects()
    }

    static let shared = LoggerManager()

    private func registerLogger(_ logger: IdentifiableLogger) {
        guard loggers.object(forKey: logger.id) == nil else { return }
        loggers.setObject(logger, forKey: logger.id)
    }

    // If the logger exists, it is returned, otherwise it is created.
    func get(
        _ subsystem: String,
        category: String,
        shouldLogToFile: Bool = true
    ) -> IdentifiableLogger {
        queue.sync {
            let id = Identifier(subsystem, category)

            if let existingLogger = loggers.object(forKey: id) {
                return existingLogger
            }

            let logger = IdentifiableLogger(
                subsystem: subsystem,
                category: category,
                delegate: shouldLogToFile ? self : nil
            )

            self.registerLogger(logger)
            return logger
        }
    }
}

extension LoggerManager: IdentifiableLoggerDelegate {
    func didLog(_ string: String) {
        fileWriter.write(string)
    }

    func getLogs() throws -> String {
        try fileWriter.getLogs()
    }
}

public protocol IdentifiableLoggerDelegate: AnyObject {
    func didLog(_ string: String)
    func getLogs() throws -> String
}
