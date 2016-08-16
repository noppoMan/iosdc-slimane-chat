import Slimane
import WS

enum MessageType: String {
    case message
}

struct ChatSocketMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void) {
        let wsServer = WebSocketServer { socket, request in
            guard let roomName = request.uri.singleValuedQuery["room_name"] else {
                return
            }
            
            do {
                let socket = try SlimaneIO(channel: roomName, socket: socket)

                socket.onText(for: MessageType.message.rawValue) { data in
                    do {
                        try socket.broadcast(to: MessageType.message.rawValue, json: data)
                    } catch {
                        logger.error("\(error)")
                    }
                }

                socket.onClose {
                    print("Closed")
                }

            } catch {
                logger.error("\(error)")
            }
        }
        
        wsServer.respond(to: request, chainingTo: next, result: result)
    }
}
