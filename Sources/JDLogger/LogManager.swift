// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog
import SwiftUI

final class LoggerManager: @unchecked Sendable {
    /*
     Contains a dictionary of loggers using their identifiers as key.

     Both the key and the logger are weakly held objects. Once they are no longer in use,
     they are automatically removed.
     */
    internal private(set) var loggers: NSMapTable<Identifier<IdentifiableLogger>, IdentifiableLogger>
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
        _ category: String,
        fileOperation: FileOperation
    ) -> IdentifiableLogger {
        queue.sync {
            let id = Identifier(subsystem, category)

            if let existingLogger = loggers.object(forKey: id) {
                return existingLogger
            }

            let logger = IdentifiableLogger(
                subsystem: subsystem,
                category: category,
                logWriter: fileOperation == .write ? fileWriter : nil,
                logRetriever: fileWriter,
                fileModifier: fileWriter
            )

            self.registerLogger(logger)
            return logger
        }
    }
}

extension LoggerManager {
    func disableLoggers(_ identifierBuikders: [IdentifiableLoggerIDBuilder]) {
        queue.sync {
            let loggers = identifierBuikders.compactMap {
                self.loggers.object(forKey: $0.identifier)
            }

            loggers.forEach { $0.disable() }
        }
    }

    func disableLoggers(_ ids: [Identifier<IdentifiableLogger>]) {
        queue.sync {
            let loggers = ids.compactMap {
                self.loggers.object(forKey: $0)
            }

            loggers.forEach { $0.disable() }
        }
    }
}
