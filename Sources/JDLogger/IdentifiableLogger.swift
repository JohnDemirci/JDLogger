//
//  IdentifiableLogger.swift
//  
//
//  Created by John Demirci on 7/1/24.
//

import OSLog

public class IdentifiableLogger: Identifiable {
    public let id: Identifier<IdentifiableLogger>
    private let logger: os.Logger

    private weak var delegate: IdentifiableLoggerDelegate?

    public init(
        subsystem: String,
        category: String,
        delegate: IdentifiableLoggerDelegate? = nil
    ) {
        id = Identifier("\(subsystem).\(category)")
        logger = os.Logger(subsystem: subsystem, category: category)
        self.delegate = delegate
    }

    /// Logs the Message as well as the file, function, and line where it was called from.
    /// If logToFile is enabled, it writes to the file.
    ///
    /// - Parameters:
    ///   - messagge: An autoclosure that returns ``String``.
    ///   - file:the filename. Default value is set to `#file`
    ///   - function: the function name. Default value is set to `#function`
    ///   - line: the line number. Default value is set to `#line`
    public func info(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let printable = "[\(Date())] [INFO] [\((file as NSString).lastPathComponent)] [\(function)] [\(line)] message:\n\(message())\n"

        logger.info("\(printable)")
        delegate?.didLog(printable)
    }

    /// Logs the message as well as the file function and line this function was called from.
    ///
    /// - Important: This function does nothing outside of `DEBUG` builds
    ///
    /// - Parameters:
    ///    - messagge: An autoclosure that returns ``String``.
    ///    - file:the filename. Default value is set to `#file`
    ///    - function: the function name. Default value is set to `#function`
    ///    - line: the line number. Default value is set to `#line`
    public func debug(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let printable = "[\(Date())] [DEBUG] [\((file as NSString).lastPathComponent)] [\(function)] [\(line)] message:\n\(message())\n"
        logger.debug("\(printable)")
        #endif
    }

    /// Logs the message, error message, file, function and line this function was called from.
    /// Logs the message into the file if logToFile was enabled when creating the Logger property wrapper.
    ///
    /// - Important: The assertion failure won't be raised in RELEASE builds
    ///
    /// - Parameters:
    ///    - messagge: An autoclosure that returns ``String``.
    ///    - error: the received error. It is used to construct a bigger log message to displauy the debugDescription. Default value is nil
    ///    - shouldRaiseAssertionFailure: A ``Bool`` flag that will raise assertion failure. This does nothing outside of DEBUG builds.
    ///    - file:the filename. Default value is set to `#file`
    ///    - function: the function name. Default value is set to `#function`
    ///    - line: the line number. Default value is set to `#line`
    public func error(
        _ message: @autoclosure () -> String,
        error: Error? = nil,
        shouldRaiseAssertionFailure: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var _message = message()

        if let error {
            _message.append("\n\(error.localizedDescription)")
        }

        let printable = "[\(Date())] [ERROR] [\((file as NSString).lastPathComponent)] [\(function)] [\(line)] message:\n\(_message)\n"

        logger.error("\(printable)")
        delegate?.didLog(printable)

        if shouldRaiseAssertionFailure {
            assertionFailure(_message)
        }
    }

    /// Reads the logs from the file.
    ///
    /// - Returns: An optional String
    ///
    /// - Note: If writingToFile flag is not enabled, then this operation returns nil.
    public func getLogs() -> String? {
        try? delegate?.getLogs()
    }
}

extension IdentifiableLogger: Equatable {
    public static func == (lhs: IdentifiableLogger, rhs: IdentifiableLogger) -> Bool {
        lhs.id == rhs.id
    }
}
