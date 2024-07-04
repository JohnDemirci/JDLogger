//
//  FileWriterTests.swift
//  
//
//  Created by John Demirci on 7/4/24.
//

import XCTest
@testable import JDLogger

final class FileWriterTests: XCTestCase {
    private var fileWriter: FileLogWriter!

    override func setUp() {
        super.setUp()
        self.fileWriter = FileLogWriter()
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: FileLogWriter.filenameStorageKey)
        deleteFile()
        self.fileWriter = nil
    }
}

extension FileWriterTests {
    func deleteFile() {
        let path = FileLogWriter.getFilePath(self.fileWriter.fileName)
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}

// MARK: - Test Write and Get Logs

extension FileWriterTests {
    func testWrite() {
        let textToWrite = "London is Red"
        fileWriter.write(textToWrite)

        let retrievedLogs = try? fileWriter.getLogs()

        XCTAssertEqual(textToWrite, retrievedLogs)
    }
}

// MARK: - Test file name change

extension FileWriterTests {
    func testFileNameChange() {
        let newName = "arsenal"
        try? fileWriter.changeFile(to: newName)

        XCTAssertEqual(fileWriter.fileName, newName)
        XCTAssertEqual(fileWriter.fileURL, URL(filePath: FileLogWriter.getFilePath(newName)))
        XCTAssertEqual(UserDefaults.standard.string(forKey: FileLogWriter.filenameStorageKey), newName)
    }

    func testFileNameChangeRemovesOldFile() {
        let oldName = "Logs"
        let newName = "gunners"

        // validation of old value
        XCTAssertEqual(fileWriter.fileName, oldName)
        XCTAssertTrue(FileManager.default.fileExists(atPath: FileLogWriter.getFilePath(oldName)))

        try? fileWriter.changeFile(to: newName)

        XCTAssertFalse(FileManager.default.fileExists(atPath: FileLogWriter.getFilePath(oldName)))
        XCTAssertTrue(FileManager.default.fileExists(atPath: FileLogWriter.getFilePath(newName)))
    }

    func testChangeFileNameToTheExistingNameThrowsError() {
        let currentName = "Logs"

        // validate
        XCTAssertEqual(fileWriter.fileName, currentName)

        // assert
        XCTAssertThrowsError(try fileWriter.changeFile(to: currentName))
    }

    func testChangeFileNameToEmptyStringThrowsError() {
        let currentName = "Logs"

        // validate
        XCTAssertEqual(fileWriter.fileName, currentName)

        // assert
        XCTAssertThrowsError(try fileWriter.changeFile(to: ""))
    }
}
