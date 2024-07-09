//
//  LoggerConfigurator.swift
//  
//
//  Created by John Demirci on 7/8/24.
//

import Foundation

public final class LoggerConfigurator {
    /// Provides an array of all the disabledLoggers
    public var disabledLoggers: [IdentifiableLogger] {
        LoggerManager
            .shared
            .loggers
            .dictionaryRepresentation()
            .reduce(into: [IdentifiableLogger]()) { partialResult, keyValuePair in
                if keyValuePair.value.isDisabled {
                    partialResult.append(keyValuePair.value)
                }
            }
    }

    /// Adds additional configurations to the logger(s)
    ///
    /// # Usage
    /// ```swift
    /// struct SomeView: View {
    ///     private let configurator = LoggerConfigurator()
    ///
    ///     var body: some View {
    ///         EmptyView()
    ///     }
    ///
    ///     func configure() {
    ///         //configurator.disableLoggers([ /* add loggers here */ ])
    ///         //configurator.enableDisabledLoggers()
    ///         //configurator.disabledLoggers
    ///     }
    /// }
    /// ```
    public init() { }

    /// Enables all the disabled loggers.
    public func enableDisabledLoggers() {
        disabledLoggers.forEach { $0.enable() }
    }

    /// Disables the provided loggers
    ///
    /// - Parameters:
    ///    - idBuilder: Array of ``IdentifiableLoggerIDBuilder``
    public func disableLoggers(_ idBuilder: [IdentifiableLoggerIDBuilder]) {
        LoggerManager.shared.disableLoggers(idBuilder)
    }

    /// Disables the provided loggers.
    ///
    /// - Parameters:
    ///    - idBuilder: Array of ``Identifier<IdentifiableLogger>``
    public func disableLoggers(_ ids: [Identifier<IdentifiableLogger>]) {
        LoggerManager.shared.disableLoggers(ids)
    }
}
