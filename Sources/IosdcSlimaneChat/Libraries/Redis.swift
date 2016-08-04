import SwiftRedis

extension Redis {

  public static func publish(_ connection: SwiftRedis.Connection, channel: String, data: String, callback: (SwiftRedis.GenericResult<Any>) -> ()) {
      Redis.command(connection, command: .RAW(["PUBLISH", channel, data]), completion: callback)
  }

  public static func subscribe(_ connection: SwiftRedis.Connection, channel: String, callback: (SwiftRedis.GenericResult<Any>) -> ()) {
      Redis.command(connection, command: .RAW(["SUBSCRIBE", channel]), completion: callback)
  }

  public static func unsubscribe(_ connection: SwiftRedis.Connection, channel: String, callback: (SwiftRedis.GenericResult<Any>) -> ()) {
      Redis.command(connection, command: .RAW(["UNSUBSCRIBE", channel]), completion: callback)
  }
}
