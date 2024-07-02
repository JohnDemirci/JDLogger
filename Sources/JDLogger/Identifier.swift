//
//  Identifier.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

import Foundation

/// Used as a unique Identifier. This is an object and used for automatically de-referencing when the logger is no longer in use.
public class Identifier<T: AnyObject>: Identifiable, Equatable {
    public static func == (lhs: Identifier<T>, rhs: Identifier<T>) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String

    init(_ id: String) {
        self.id = id
    }
}

extension Identifier where T == IdentifiableLogger {
    convenience init(_ subsystem: String, _ category: String) {
        self.init("\(subsystem).\(category)")
    }
}
