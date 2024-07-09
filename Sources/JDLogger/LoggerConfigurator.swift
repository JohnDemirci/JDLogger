//
//  LoggerConfigurator.swift
//  
//
//  Created by John Demirci on 7/8/24.
//

import Foundation

public final class LoggerConfigurator {
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

    public init() { }

    public func enableDisabledLoggers() {
        disabledLoggers.forEach { $0.enable() }
    }

    public func disableLoggers(_ idBuilder: [IdentifiableLoggerIDBuilder]) {
        LoggerManager.shared.disableLoggers(idBuilder)
    }

    public func disableLoggers(_ ids: [Identifier<IdentifiableLogger>]) {
        LoggerManager.shared.disableLoggers(ids)
    }
}
