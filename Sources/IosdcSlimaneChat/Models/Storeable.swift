import CLibUv
import SwiftRedis
import Thrush

private var con: SwiftRedis.Connection?

protocol Storeable {
  var key: String { get }
  func serialize() throws -> String
}

extension Storeable {
    func save() -> Promise<Self> {
        return Promise { resolve, reject in
            do {
                con = try SwiftRedis.Connection(loop: uv_default_loop())
            } catch {
                return reject(error)
            }
            
            do {
                let serializedString = try self.serialize()
                Redis.command(con!, command: .SET(self.key, serializedString)) { result in
                    if case .success(_) = result {
                        resolve(self)
                    }
                    else if case .error(let error) = result {
                        reject(error)
                    }
                }
            } catch {
                reject(error)
            }
        }
    }
}
