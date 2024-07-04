//
//  LoggerManagerTests.swift
//  
//
//  Created by John Demirci on 7/4/24.
//

import XCTest
@testable import JDLogger

final class LoggerManagerTests: XCTestCase {
    var logManager: LoggerManager!
    override func setUp() {
        super.setUp()
        logManager = .shared
    }

    override func tearDown() {
        super.tearDown()
        logManager = nil
    }
}

extension LoggerManagerTests {
    func testGetNewLogger() {
        let subsystem = "subsystem"
        let category = "category"

        let logger = logManager.get(subsystem, category, fileOperation: .ignoreFile)

        let expectedID = Identifier<IdentifiableLogger>(subsystem, category)
        XCTAssertEqual(expectedID, logger.id)
    }
}
