//
//  LoggerConfiguratorTests.swift
//  
//
//  Created by John Demirci on 7/9/24.
//

import Foundation
import XCTest
@testable import JDLogger

final class LoggerConfiguratorTests: XCTestCase {
    func testDisableLoggersUsingIdentifier() {
        // setup
        @Logger("subsystem", "category", .ignoreFile) var logger
        @Logger("subsystem2", "category2", .ignoreFile) var logger2
        @Logger("subsystem3", "category3", .ignoreFile) var logger3
        let configurator = LoggerConfigurator()

        // validate initial case
        XCTAssertTrue(configurator.disabledLoggers.isEmpty)

        // set the data ready
        let idsToDisable: [Identifier<IdentifiableLogger>] = [
            logger.id,
            logger2.id
        ]

        // perform action
        configurator.disableLoggers(idsToDisable)

        // assert
        XCTAssertTrue(configurator.disabledLoggers.contains(where: {
            $0.id == logger.id
        }))

        XCTAssertTrue(configurator.disabledLoggers.contains(where: {
            $0.id.id == logger2.id.id
        }))

        XCTAssertFalse(configurator.disabledLoggers.contains(where: {
            $0.id.id == logger3.id.id
        }))
    }

    func testDisableLoggersUsingIdentifierBuilder() {
        // setup
        @Logger("subsystem", "category", .ignoreFile) var logger
        @Logger("subsystem2", "category2", .ignoreFile) var logger2
        @Logger("subsystem3", "category3", .ignoreFile) var logger3
        let configurator = LoggerConfigurator()

        // validate initial case
        XCTAssertTrue(configurator.disabledLoggers.isEmpty)

        // set the data ready
        let idsToDisable: [IdentifiableLoggerIDBuilder] = [
            .init(subsystem: "subsystem", category: "category"),
            .init(subsystem: "subsystem2", category: "category2")
        ]

        // perform action
        configurator.disableLoggers(idsToDisable)

        // assert
        XCTAssertTrue(configurator.disabledLoggers.contains(where: {
            $0.id == logger.id
        }))

        XCTAssertTrue(configurator.disabledLoggers.contains(where: {
            $0.id.id == logger2.id.id
        }))

        XCTAssertFalse(configurator.disabledLoggers.contains(where: {
            $0.id.id == logger3.id.id
        }))
    }

    func testEnableDisabledLoggers() {
        // setup
        @Logger("subsystem", "category", .ignoreFile) var logger
        @Logger("subsystem2", "category2", .ignoreFile) var logger2
        @Logger("subsystem3", "category3", .ignoreFile) var logger3
        let configurator = LoggerConfigurator()

        // validate initial case
        XCTAssertTrue(configurator.disabledLoggers.isEmpty)

        // set the data ready
        let idsToDisable: [Identifier<IdentifiableLogger>] = [
            logger.id,
            logger2.id
        ]

        // perform action
        configurator.disableLoggers(idsToDisable)

        configurator.enableDisabledLoggers()
        XCTAssertTrue(configurator.disabledLoggers.isEmpty)
    }
}
