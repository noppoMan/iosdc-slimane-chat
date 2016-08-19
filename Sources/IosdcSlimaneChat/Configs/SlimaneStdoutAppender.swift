import Time

public struct SlimaneStdoutAppender: Appender {
    public let name: String
    public var levels: Logger.Level
    
    init(name: String = "Standard Output Appender", levels: Logger.Level = .all) {
        self.name = name
        self.levels = levels
    }
    
    public func append(event: Logger.Event) {
        var logMessage = ""
        
        logMessage += "[" + event.timestamp + "]"
        logMessage += "[" + String(describing: event.locationInfo) + "]"
        
        if let message = event.message {
            logMessage += ":" + String(describing: message)
        }
        
        if let error = event.error {
            logMessage += ":" + String(describing: error)
        }
        
        print(logMessage)
    }
}
