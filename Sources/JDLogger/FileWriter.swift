//
//  FileWriter.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

import Foundation

final class FileLogWriter {
    static var filenameStorageKey: String {
        ".JDLogger.com.filename_storageKey"
    }

    enum Failure: Error, CustomStringConvertible {
        case message(String)

        var description: String {
            switch self {
            case .message(let errorMessage):
                return errorMessage
            }
        }
    }

    private let queue = DispatchQueue(label: "com.john.demirci.filelogwriter", qos: .background)
    private let readerQueue = DispatchQueue(label: "com.john.demirci.filelogwriter.reader", qos: .background)
    private let fileManager: FileManager
    private let lock = NSRecursiveLock()

    private(set) var fileName: String
    private(set) var fileURL: URL
    private(set) var fileWriter: FileHandle

    init() {
        let name = UserDefaults.standard.string(forKey: Self.filenameStorageKey) ?? "Logs"

        self.fileName = name
        self.fileManager = .default

        let filePath = Self.getFilePath(name)
        try? Self.createFile(name)

        self.fileWriter = FileHandle(forWritingAtPath: filePath)!
        self.fileURL = URL(filePath: filePath)
    }
}

extension FileLogWriter: LogWritable {
    func write(_ string: String) {
        queue.sync { [unowned self] in
            self.fileWriter.seekToEndOfFile()
            guard let data = string.data(using: .utf8) else {
                assertionFailure("could not convert string to raw data")
                return
            }

            self.fileWriter.write(data)
        }
    }
}

extension FileLogWriter: LogRetrievable {
    public func getLogs() throws -> String {
        // avoid abusing this function by adding a lock
        try lock.withLock {
            try readerQueue.sync {
                try String(
                    contentsOf: self.fileURL,
                    encoding: .utf8
                )
            }
        }
    }
}

extension FileLogWriter: FileModifiable {
    public func changeFile(to name: String) throws {
        guard name != self.fileName else {
            throw Failure.message("Cannot rename the file to the existing name")
        }

        guard !name.isEmpty else {
            throw Failure.message("filename must contain letters")
        }

        // close file
        try queue.sync { [weak self] in
            guard let self else { throw Failure.message("self is nil") }
            try self.fileWriter.close()
        }

        // create file
        try queue.sync {
            // remove old file
            try FileManager.default.removeItem(atPath: Self.getFilePath(self.fileName))
            try Self.createFile(name)
        }

        // update local variables
        try queue.sync { [unowned self] in
            let filePath = Self.getFilePath(name)

            guard let newFileHandler = FileHandle(forWritingAtPath: filePath) else {
                throw Failure.message("new file handler at the path \(filePath) is nil")
            }

            self.fileWriter = newFileHandler
            self.fileURL = URL(filePath: filePath)
            self.fileName = name
        }

        queue.sync {
            UserDefaults.standard.setValue(name, forKey: Self.filenameStorageKey)
        }
    }
}

// MARK: - Helpers

extension FileLogWriter {
    static func getFilePath(_ name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = documentDirectory.appendingFormat("/" + "\(name).txt")
        return filePath
    }

    // Creates a text file with the given name.
    // Removes the pre-existing text file containing the same name if it exists
    static func createFile(_ name: String) throws {
        let filePath = Self.getFilePath(name)

        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(atPath: filePath)
        }

        FileManager.default.createFile(atPath: filePath, contents: nil)
    }
}

/// Protocol conformed by the FileLogWriter class to write to a file
public protocol LogWritable: AnyObject {
    func write(_ string: String)
}

/// Protocol conformed by the FileLogWriter class to retrieve the logs from the file
public protocol LogRetrievable: AnyObject {
    func getLogs() throws -> String
}

/// Protocol conformed by the FileLogWriter class to change the file name.
public protocol FileModifiable: AnyObject {
    func changeFile(to name: String) throws
}
