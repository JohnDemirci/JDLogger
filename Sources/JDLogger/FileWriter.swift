//
//  FileWriter.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

import Foundation

final class FileLogWriter {
    private let queue = DispatchQueue(label: "com.john.demirci.filelogwriter", qos: .background)
    private let readerQueue = DispatchQueue(label: "com.john.demirci.filelogwriter.reader", qos: .background)

    private let fileURL: URL
    private let fileWriter: FileHandle
    private let fileManager: FileManager

    let lock = NSRecursiveLock()

    init() {
        self.fileManager = .default

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = documentDirectory.appendingFormat("/" + "Logs.txt")

        try? fileManager.removeItem(atPath: filePath)

        fileManager.createFile(atPath: filePath, contents: nil)

        self.fileWriter = FileHandle(forWritingAtPath: filePath)!
        self.fileURL = URL(filePath: filePath)
    }
}

extension FileLogWriter {
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

    func getLogs() throws -> String {
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
