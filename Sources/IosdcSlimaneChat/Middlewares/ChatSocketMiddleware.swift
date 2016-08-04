import Slimane
import WS

enum MessageType: String {
    case message
}

struct ChatSocketMiddleware: AsyncMiddleware {

  func respond(to request: Request, chainingTo next: AsyncResponder, result: ((Void) throws -> Response) -> Void) {
    let wsServer = WebSocketServer { socket, request in

      guard let _roomName = request.query["room_name"]?.first, let roomName = _roomName else {
          return
      }

      do {
        let socket = try SlimaneIO(channel: roomName, socket: socket)

        socket.onText(for: MessageType.message.rawValue) { data in
          socket.broadcast(to: MessageType.message.rawValue, json: data)
        }

        socket.onClose {
            print("Closed")
        }

      } catch {
          print(error)
      }
    }
    wsServer.respond(to: request, chainingTo: next, result: result)
  }
}
