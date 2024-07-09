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

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    public var identifier: Identifier<IdentifiableLogger> {
        Identifier(subsystem, category)
    }
}
