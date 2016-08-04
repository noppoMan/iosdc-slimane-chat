import Time

public struct SlimaneStdoutAppender: Appender {
    public let name: String
    public var closed: Bool
    public var level: Log.Level

    public init(name: String = "PMSStdoutAppender", closed: Bool = false, level: Log.Level = .all) {
        self.name = name
        self.closed = closed
        self.level = level
    }

    public func append(_ event: LoggingEvent) {
        var logMessage = ""

        var level = "ALL"
        if event.level.contains(Log.Level.info) {
            level = "INFO"
        }
        else if event.level.contains(Log.Level.debug) {
            level = "DEBUG"
        }
        else if event.level.contains(Log.Level.error) {
            level = "ERROR"
        }
        else if event.level.contains(Log.Level.fatal) {
            level = "FATAL"
        }

        logMessage += "[\(name):\(level)] [\(Time(unixtime: event.timestamp))] [\(Process.pid)]"

        if let message = event.message {
            logMessage += ": \(message)"
        }
        if let error = event.error {
            logMessage += ": \(error)"
        }

        print(logMessage)
    }
}
