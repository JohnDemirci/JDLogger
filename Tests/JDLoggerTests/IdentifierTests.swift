//
//  IdentifierTests.swift
//  
//
//  Created by John Demirci on 7/4/24.
//

import XCTest
@testable import JDLogger

final class IdentifierTests: XCTestCase {
    func testIdentifierInitializerEqualsToGivenString() {
        let identifier = Identifier<SampleClass>("sampleID")
        XCTAssertEqual(identifier.id, "sampleID")
    }

    func testIdentifiersEqual() {
        let identifier = Identifier<SampleClass>("sampleID")
        let identifier2 = Identifier<SampleClass>("sampleID")
        XCTAssertEqual(identifier, identifier2)
    }

    func testIdentifiersNotEqual() {
        let identifier = Identifier<SampleClass>("sampleID")
        let identifier2 = Identifier<SampleClass>("sampleID1")
        XCTAssertNotEqual(identifier, identifier2)
    }

    func testIdentifierWithIndentifiableLogger() {
        let subsystem = "londonIs"
        let category = "arsenal"
        let identifier = Identifier<IdentifiableLogger>(subsystem, category)

        XCTAssertEqual(identifier.id, "\(subsystem).\(category)")
    }
}

private class SampleClass {}
