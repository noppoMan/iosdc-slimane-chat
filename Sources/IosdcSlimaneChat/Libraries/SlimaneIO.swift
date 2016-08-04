import WS
import SwiftRedis
import JSON
import Foundation

private func uuidGenerate() -> String {
    #if os(Linux)
        return NSUUID().UUIDString
    #else
        return NSUUID().uuidString
    #endif
}

extension WebSocket: Equatable {
    var id: String? {
        get {
            return storage["id"] as? String
        }

        set {
            storage["id"] = newValue
        }
    }

    func send(json: JSON) {
        var json = json
        if let id = id {
          json["socketid"] = "\(id)"
        }
        send(JSONSerializer().serializeToString(json: json))
    }
}


public func ==(lhs:WebSocket, rhs: WebSocket) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class SlimaneIO {

    private static var sockets: [String: [WebSocket]] = [:]

    private static var redisPubCon: SwiftRedis.Connection?

    private static var redisSubCon: SwiftRedis.Connection?

    enum BroadCastSocketError: ErrorProtocol {
        case configureShouldBeCalled
    }

    let socket: WebSocket

    let channel: String

    var retainedSelf: Unmanaged<SlimaneIO>? = nil

    private var onCloseHandler: (Void) -> Void = { _ in }

    private var handlers: [String: (JSON) -> Void] = [:]

    init(channel: String, socket: WebSocket) throws {
        guard let subCon = SlimaneIO.redisSubCon, _ = SlimaneIO.redisPubCon else {
            throw BroadCastSocketError.configureShouldBeCalled
        }

        self.channel = channel
        self.socket = socket
        self.socket.id = uuidGenerate()

        self.retainedSelf = Unmanaged.passRetained(self)

        if let _ = SlimaneIO.sockets[channel] {
            SlimaneIO.sockets[channel]?.append(socket)
        } else {
            SlimaneIO.sockets[channel] = [socket]

            // subscribe redis
            Redis.subscribe(subCon, channel: channel) { [unowned self] result in
                if case .Success(let rep) = result {
                    guard let rep = rep as? [String], sockets = SlimaneIO.sockets[channel] else {
                        return
                    }

                    do {
                        let content = rep[2]
                        var json = try JSONParser().parse(data: content.data)
                        for socket in sockets {
                            guard let toSocketId = socket.id else {
                                continue
                            }

                            if let fromSocketId = json["socketid"]?.stringValue where toSocketId == fromSocketId {
                                continue
                            }

                            socket.send(json: json)
                        }
                    } catch {
                        // noop
                        print(error)
                    }
                }
            }
        }

        let json: JSON = []
        self.emit(to: "connect", json: json)

        socket.onClose { [unowned self] _ in
          if let sockets = SlimaneIO.sockets[channel], let index = sockets.index(of: self.socket) {
            SlimaneIO.sockets[channel]?.remove(at: index)
          }
          self.onCloseHandler()
          self.retainedSelf?.release()
        }
    }

    static func configure(redisPubConnection: SwiftRedis.Connection, redisSubConnection: SwiftRedis.Connection){
        SlimaneIO.redisPubCon = redisPubConnection
        SlimaneIO.redisSubCon = redisSubConnection
    }

    func onText(for name: String, handler: (JSON) -> Void){
        self.handlers[name] = handler

        socket.onText { [unowned self] text in
            do {
              let json = try JSONParser().parse(data: text.data)
              if let handler = self.handlers[name], data = json["data"] {
                  handler(data)
              }
            } catch {
                print(error)
            }
        }
    }

    func onClose(_ handler: (Void) -> Void) {
      self.onCloseHandler = handler
    }

    func emit(to event: String, json: JSON){
       let json: JSON = ["event": "\(event)", "data": json]
       socket.send(json: json)
    }

    func broadcast(to event: String, json: JSON){
        let json: JSON = ["event": "\(event)", "data": json, "socketid": "\(socket.id!)"]
        let jsonString = JSONSerializer().serializeToString(json: json)
        Redis.publish(SlimaneIO.redisPubCon!, channel: channel, data: jsonString) { _ in }
    }
}
