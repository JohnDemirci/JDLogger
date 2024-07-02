import XCTest
@testable import JDLogger

final class JDLoggerTests: XCTestCase {
    private var loggerManager: LoggerManager?

    override func setUp() {
        super.setUp()
        loggerManager = .shared
    }

    override func tearDown() {
        super.tearDown()
        loggerManager = nil
    }
}

extension JDLoggerTests {
    func testSameLoggerIsUsed() {
        @Logger("one", "two", shouldLogToFile: false) var firstLogger
        @Logger("one", "two", shouldLogToFile: false) var secondLogger

        XCTAssertEqual(loggerManager?.loggers.count, 1)
        XCTAssertEqual(firstLogger, secondLogger)
    }

    func testDifferentObjectsCanHaveLoggers() {
        class LoggerTestObject {
            @Logger("john", "demirci", shouldLogToFile: false) private var logger
        }

        @Logger("john", "sample", shouldLogToFile: false) var logger
        let obj: LoggerTestObject? = LoggerTestObject()

        XCTAssertEqual(loggerManager?.loggers.count, 2)
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
