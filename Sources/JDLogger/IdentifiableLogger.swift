//
//  IdentifiableLogger.swift
//  
//
//  Created by John Demirci on 7/1/24.
//

import OSLog

/// Main Logger used by the ``Logger`` propertyWrapper.
///
/// - Important: Create an ``IdentifiableLogger`` using the ``Logger`` propertyWrapper
final public class IdentifiableLogger: Identifiable, @unchecked Sendable {
    public enum Failure: Error, CustomStringConvertible {
        case message(String)

        public var description: String {
            guard case .message(let string) = self else { return ""}
            return string
        }
    }

    public let id: Identifier<IdentifiableLogger>
    public internal(set) var isDisabled: Bool = false

    private let logger: os.Logger

    private weak var logWriter: LogWritable?
    private weak var logRetriever: LogRetrievable?
    private weak var fileModifier: FileModifiable?

    init(
        subsystem: String,
        category: String,
        logWriter: LogWritable? = nil,
        logRetriever: LogRetrievable,
        fileModifier: FileModifiable
    ) {
        self.id = Identifier(subsystem, category)
        self.logger = os.Logger(subsystem: subsystem, category: category)
        self.logWriter = logWriter
        self.logRetriever = logRetriever
        self.fileModifier = fileModifier
    }

    /// Logs the Message as well as the file, function, and line where it was called from.
    /// If logToFile is enabled, it writes to the file.
    ///
    /// - Parameters:
    ///   - message: An autoclosure that returns `String`.
    ///   - file:the filename. Default value is set to `#file`
    ///   - function: the function name. Default value is set to `#function`
    ///   - line: the line number. Default value is set to `#line`
    @Sendable
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !isDisabled else { return }
        let logMessage = logFormattedMessage(
            message,
            severity: .info,
            file: file,
            function: function,
            line: line
        )

        logger.info("\(logMessage)")
        logWriter?.write(logMessage)
    }

    /// Logs the message as well as the file function and line this function was called from.
    ///
    /// - Important: This function does nothing outside of `DEBUG` builds
    ///
    /// - Parameters:
    ///    - message: An autoclosure that returns `String`.
    ///    - file:the filename. Default value is set to `#file`
    ///    - function: the function name. Default value is set to `#function`
    ///    - line: the line number. Default value is set to `#line`
    @Sendable
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        guard !isDisabled else { return }
        let logMessage = logFormattedMessage(
            message,
            severity: .debug,
            file: file,
            function: function,
            line: line
        )
        logger.debug("\(logMessage)")
        #endif
    }

    /// Logs the message, error message, file, function and line this function was called from.
    /// Logs the message into the file if logToFile was enabled when creating the Logger property wrapper.
    ///
    /// - Important: The assertion failure won't be raised in RELEASE builds
    ///
    /// - Parameters:
    ///    - message: An autoclosure that returns `String`.
    ///    - error: the received error. It is used to construct a bigger log message to displauy the debugDescription. Default value is nil
    ///    - shouldRaiseAssertionFailure: A `Bool` flag that will raise assertion failure. This does nothing outside of DEBUG builds.
    ///    - file:the filename. Default value is set to `#file`
    ///    - function: the function name. Default value is set to `#function`
    ///    - line: the line number. Default value is set to `#line`
    @Sendable
    public func error(
        _ message: String,
        error: Error? = nil,
        shouldRaiseAssertionFailure: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !isDisabled else { return }
        var _message = message

        if let error {
            _message.append("\n\(error.localizedDescription)")
        }

        let logMessage = logFormattedMessage(
            _message,
            severity: .error,
            file: file,
            function: function,
            line: line
        )

        logger.error("\(logMessage)")
        logWriter?.write(logMessage)

        if shouldRaiseAssertionFailure {
            assertionFailure(_message)
        }
    }

    /// Logs the Message as well as the file, function, and line where it was called from.
    /// If logToFile is enabled, it writes to the file.
    ///
    /// - Parameters:
    ///   - message: An autoclosure that returns `String`.
    ///   - file:the filename. Default value is set to `#file`
    ///   - function: the function name. Default value is set to `#function`
    ///   - line: the line number. Default value is set to `#line`
    @Sendable
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !isDisabled else { return }
        let logMessage = logFormattedMessage(
            message,
            severity: .warning,
            file: file,
            function: function,
            line: line
        )

        logger.info("\(logMessage)")
        logWriter?.write(logMessage)
    }

    /// Reads the logs from the file.
    ///
    /// - Returns: A Result. Fails when logRetriever is nil, or when the content cannot be decoded to a string.
    public func getLogs() -> Result<String, Error> {
        guard let logRetriever else {
            return .failure(Failure.message("log retriever is nil"))
        }

        do {
            return .success(try logRetriever.getLogs())
        } catch {
            return .failure(error)
        }
    }

    /// Changes the name of the file in the Document directory.
    ///
    /// - Important: Any logs saved in the previous file will be removed.
    public func changeTextFileName(to name: String) -> Result<Void, Error> {
        guard let fileModifier else {
            return .failure(Failure.message("file modifier is nil"))
        }

        do {
            try fileModifier.changeFile(to: name)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// Enabled the logger
    ///
    /// - Note: If the logger is already enabled, does nothing
    public func enable() {
        self.isDisabled = false
    }

    /// Disables the current logger.
    ///
    /// - Note: If the logger is disabled, does nothing
    public func disable() {
        self.isDisabled = true
    }
}

extension IdentifiableLogger {
    func logFormattedMessage(
        _ message: @autoclosure () -> String,
        severity: LogSeverity,
        file: String,
        function: String,
        line: Int
    ) -> String {
        "[\(Date())] [\(severity.rawValue)] [\((file as NSString).lastPathComponent)] [\(function)] [\(line)] message:\n\(message())\n"
    }
}

extension IdentifiableLogger: Hashable {
    public static func == (lhs: IdentifiableLogger, rhs: IdentifiableLogger) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
