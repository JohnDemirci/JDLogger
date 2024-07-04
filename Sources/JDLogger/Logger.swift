//
//  FileLogger.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

import Foundation

@propertyWrapper
public struct Logger {
    public typealias Value = IdentifiableLogger

    public var wrappedValue: Value

    /// If the logger matching with the `subsystem` and `category` already exists, uses the existing logger, otherwise, creates a logger.
    public init(
        _ subsystem: String,
        _ category: String,
        _ fileOperation: FileOperation = .write
    ) {
        self.wrappedValue = LoggerManager.shared.get(
            subsystem,
            category,
            fileOperation: fileOperation
        )
    }
}
