//
//  IdentifiableLoggerTests.swift
//  
//
//  Created by John Demirci on 7/4/24.
//

import XCTest
@testable import JDLogger

final class IdentifiableLoggerTests: XCTestCase {
    private var logger: IdentifiableLogger!
    private var mockFileWriter: MockLogFileWriter!

    override func setUp() {
        super.setUp()
        mockFileWriter = MockLogFileWriter()
        logger = IdentifiableLogger(
            subsystem: "test",
            category: "category",
            logWriter: mockFileWriter,
            logRetriever: mockFileWriter,
            fileModifier: mockFileWriter
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        mockFileWriter = nil
    }
}

// MARK: - Test initializer

extension IdentifiableLoggerTests {
    func testLoggerIdentifier() {
        let subsystem = "test"
        let category = "category"
        let logger = IdentifiableLogger(
            subsystem: subsystem,
            category: category,
            logRetriever: mockFileWriter,
            fileModifier: mockFileWriter
        )

        XCTAssertEqual(logger.id.id, "\(subsystem).\(category)")
    }
}

// MARK: - Test file writing logging functions

extension IdentifiableLoggerTests {
    func testLogInfoCallsWriteFunction() {
        let message = "info log message"
        logger.info(message)
        XCTAssertTrue(mockFileWriter.didCallWrite)
    }

    func testLogErrorCallsWriteFunction() {
        let message = "error log message"
        logger.error(message)
        XCTAssertTrue(mockFileWriter.didCallWrite)
    }

    func testLogWarningCallsWriteFunction() {
        let message = "warning log message"
        logger.warning(message)
        XCTAssertTrue(mockFileWriter.didCallWrite)
    }

    func testLogDebugNotCallsWriteFunction() {
        let message = "debug log message"
        logger.debug(message)
        XCTAssertFalse(mockFileWriter.didCallWrite)
    }
}

// MARK: - Test getLogs

extension IdentifiableLoggerTests {
    func testGetLogs() {
        switch logger.getLogs() {
        case .success:
            XCTAssertTrue(mockFileWriter.didCallGetLogs)
        case .failure:
            XCTFail()
        }
    }

    func testGetLogsFailure()  {
        mockFileWriter.throwGetLogs = true
        switch logger.getLogs() {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testGetLogsWithoutLogRetrieverThrowsError() {
        self.mockFileWriter = nil
        switch logger.getLogs() {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
}

// MARK: - Test changeTextFileName

extension IdentifiableLoggerTests {
    func testChangeTextFileName() {
        _ = logger.changeTextFileName(to: "something")
        XCTAssertEqual(mockFileWriter.didChangeFileName, "something")
    }

    func testChangeTextFileNameFailure() {
        mockFileWriter.throwChangeFileName = true
        let result = logger.changeTextFileName(to: "something")

        switch result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testChangeTextFileNameWithoutFileModifier() {
        mockFileWriter = nil
        let result = logger.changeTextFileName(to: "something")

        switch result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
}

final private class MockLogFileWriter {
    enum Failure: Error {
        case error
    }

    fileprivate var didCallWrite: Bool = false
    fileprivate var didChangeFileName: String?
    fileprivate var didCallGetLogs: Bool = false
    fileprivate var throwChangeFileName: Bool = false
    fileprivate var throwGetLogs: Bool = false
}

extension MockLogFileWriter: LogWritable {
    func write(_ string: String) {
        didCallWrite = true
    }
}

extension MockLogFileWriter: FileModifiable {
    func changeFile(to name: String) throws {
        if throwChangeFileName {
            throw Failure.error
        }
        self.didChangeFileName = name
    }
}

extension MockLogFileWriter: LogRetrievable {
    func getLogs() throws -> String {
        if throwGetLogs {
            throw Failure.error
        }
        self.didCallGetLogs = true
        return "logs"
    }
}
