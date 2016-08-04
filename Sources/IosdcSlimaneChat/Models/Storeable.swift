import CLibUv
import SwiftRedis
import Thrush

private var con: SwiftRedis.Connection?

protocol Storeable {
  var key: String { get }
  func serialize() -> String
}

extension Storeable {
  func save() -> Promise<Self> {
    return Promise { resolve, reject in
      do {
          con = try SwiftRedis.Connection(loop: uv_default_loop())
      } catch {
        return reject(error)
      }

      Redis.command(con!, command: .SET(self.key, self.serialize())) { result in
        if case .Success(_) = result {
            resolve(self)
        }
        else if case .Error(let error) = result {
            reject(error)
        }
      }
    }
  }
}
