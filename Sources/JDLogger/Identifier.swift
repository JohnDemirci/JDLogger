//
//  Identifier.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

import Foundation

/// Used as a unique Identifier. This is an object and used for automatically de-referencing when the logger is no longer in use.
///
/// - Note: Identifier is used as a reference type ID.
/// - Important: This object is created to provide a reference type identifier for reference type objects.
///
/// # Usage
/// ```swift
/// class SomeObject {
///     let id: Identifier<SomeObject>
///
///     init(_ id: String) {
///         self.id = Identifier<SomeObject>(id)
///     }
/// }
/// ```
public class Identifier<T: AnyObject>: Identifiable, Hashable, NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        return Identifier<T>(self.id)
    }

    public static func == (lhs: Identifier<T>, rhs: Identifier<T>) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String

    init(_ id: String) {
        self.id = id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine("\(T.self)")
    }
}

extension Identifier where T == IdentifiableLogger {
    convenience init(_ subsystem: String, _ category: String) {
        self.init("\(subsystem).\(category)")
    }
}
