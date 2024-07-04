import XCTest
@testable import JDLogger

final class JDLoggerTests: XCTestCase {
    private var loggerManager: LoggerManager?

    override func setUp() {
        super.setUp()
        createLogFile()
        loggerManager = .shared
    }

    override func tearDown() {
        super.tearDown()
        removeLogFile()
        loggerManager = nil
    }
}

extension JDLoggerTests {
    func testSameLoggerIsUsed() {
        @Logger("one", "two", .ignoreFile) var firstLogger
        @Logger("one", "two", .ignoreFile) var secondLogger

        XCTAssertEqual(loggerManager?.loggers.count, 1)
        XCTAssertEqual(firstLogger, secondLogger)
    }

    func testDifferentObjectsCanHaveLoggers() {
        class LoggerTestObject {
            @Logger("john", "demirci", .ignoreFile) private var logger
        }

        @Logger("john", "sample", .ignoreFile) var logger
        let _: LoggerTestObject? = LoggerTestObject()

        XCTAssertEqual(loggerManager?.loggers.count, 2)
    }

    func testLogFileCreated() {
        @Logger("test", "newLogger") var logger

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = documentDirectory.appendingFormat("/" + "Logs.txt")

        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
    }

    /*
     deallocation of the object happens under the hood of NSMapTable, and it is not instantanious.
     there is no way to test the zeroing of the reference in the unit tests.

     one way to test is to use a sample app and check the memory graph
     */
//    func testDeallocatingAnObjectRemovesItsLogger() async {
//        class LoggerTestObject {
//            @Logger("john", "demirci", shouldLogToFile: false) private var logger
//        }
//
//        @Logger("john", "sample", shouldLogToFile: false) var logger
//        var obj: LoggerTestObject? = LoggerTestObject()
//
//        XCTAssertEqual(loggerManager?.loggers.count, 2)
//
//        obj = nil
//
//        try? await Task.sleep(for: .seconds(1))
//
//        XCTAssertEqual(loggerManager?.loggers.count, 1)
//    }
}

extension JDLoggerTests {
    func removeLogFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = documentDirectory.appendingFormat("/" + "Logs.txt")

        try? FileManager.default.removeItem(atPath: filePath)
    }

    func createLogFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = documentDirectory.appendingFormat("/" + "Logs.txt")
        FileManager.default.createFile(atPath: filePath, contents: nil)
    }
}
