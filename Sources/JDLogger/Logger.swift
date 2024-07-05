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
    ///
    /// # @Logger can be used in SwiftUI View.
    /// ```swift
    /// struct SomeView: View {
    ///     @Logger("subsystem", "category") private var logger
    ///     var body: some View {
    ///         Text("hello world")
    ///             .onAppear { logger.info("appeared") }
    ///     }
    /// }
    /// ```
    ///
    /// # @Logger can also be used in non-SwiftUI Views
    /// ```swift
    /// class SomeClass {
    ///     @Logger("subsystem", "category", .ignoreFile) private var logger
    ///     func doSomething() {
    ///         doWork
    ///         logger.info("log message that won't be written toa  file")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///    - subsystem: String
    ///    - category: String
    ///    - fileOperation: FileOperation defaulted to `.write`
    ///
    /// - Important: If a ``Logger`` with an exsisting `subsystem` and `category` with a different ``FileOperation`` is requested, the existing logger will be returned ignoring the new ``FileOperation`` value.
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
