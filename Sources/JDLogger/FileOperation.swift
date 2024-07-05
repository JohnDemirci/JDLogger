//
//  FileOperation.swift
//  
//
//  Created by John Demirci on 7/2/24.
//

/// Operation to let the LoggerManager know if the logs of the created logger should be written to a file.
public enum FileOperation: Equatable {
    case write
    case ignoreFile
}
