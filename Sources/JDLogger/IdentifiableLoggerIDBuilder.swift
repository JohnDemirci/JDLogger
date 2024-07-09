//
//  IdentifiableLoggerIDBuilder.swift
//  
//
//  Created by John Demirci on 7/8/24.
//

import Foundation

public struct IdentifiableLoggerIDBuilder {
    public let subsystem: String
    public let category: String

    /// Helper to build Logger Identifier to be used in batches
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    public var identifier: Identifier<IdentifiableLogger> {
        Identifier(subsystem, category)
    }
}
