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

    func testDisableLoggersUsingIdentifier() {
        @Logger("subsystem", "category") var logger1
        @Logger("subsystem2", "category2") var logger2
        @Logger("subsystem3", "category3") var logger3
        @Logger("subsystem4", "category4") var logger4

        XCTAssertFalse(logger1.isDisabled)
        XCTAssertFalse(logger2.isDisabled)
        XCTAssertFalse(logger3.isDisabled)
        XCTAssertFalse(logger4.isDisabled)

        let loggerIDs: [Identifier<IdentifiableLogger>] = [
            logger1.id,
            logger2.id,
            logger3.id,
            logger4.id
        ]

        logManager.disableLoggers(loggerIDs)

        XCTAssertTrue(logger1.isDisabled)
        XCTAssertTrue(logger2.isDisabled)
        XCTAssertTrue(logger3.isDisabled)
        XCTAssertTrue(logger4.isDisabled)
    }

    func testDisableLoggersUsingIdentifierBuilder() {
        @Logger("subsystem", "category") var logger1
        @Logger("subsystem2", "category2") var logger2
        @Logger("subsystem3", "category3") var logger3
        @Logger("subsystem4", "category4") var logger4

        XCTAssertFalse(logger1.isDisabled)
        XCTAssertFalse(logger2.isDisabled)
        XCTAssertFalse(logger3.isDisabled)
        XCTAssertFalse(logger4.isDisabled)

        let loggerIDs: [IdentifiableLoggerIDBuilder] = [
            .init(subsystem: "subsystem", category: "category"),
            .init(subsystem: "subsystem2", category: "category2"),
            .init(subsystem: "subsystem3", category: "category3"),
            .init(subsystem: "subsystem4", category: "category4")
        ]

        logManager.disableLoggers(loggerIDs)

        XCTAssertTrue(logger1.isDisabled)
        XCTAssertTrue(logger2.isDisabled)
        XCTAssertTrue(logger3.isDisabled)
        XCTAssertTrue(logger4.isDisabled)
    }
}
