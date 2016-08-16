import Slimane
import JSON

extension Request {
    var isAuthenticated: Bool {
        return self.currentUser != nil
    }

    var currentUser: User? {
        get {
            return storage["currentUser"] as? User
        }

        set {
            return storage["currentUser"] = newValue
        }
    }

    mutating func login(_ user: User, callback: @escaping (Void) -> Void){
        session?["currentUser"] = user.serialize()
        let timer = TimerWrap(tick: 1000)
        timer.start {
            timer.end()
            callback()
        }
    }

    func logout() {
        session?.destroy()
    }
}

struct AuthenticationMiddleware: AsyncMiddleware {

    static func parse (to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void){
        var request = request

        if let user = request.session?["currentUser"] {
            do {
                request.currentUser = try User(json: JSONParser().parse(data: user.data))
            } catch {
                result {
                    throw error
                }
            }
        }

        next.respond(to: request, result: result)
    }

    func respond(to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void) {
        if !request.isAuthenticated {
            if request.json == nil {
                result {
                    Response(redirect: "\(APP_BASE_URL)/")
                }
            } else {
                let json: JSON = ["error": "Authentication Required"]
                result {
                    Response(status: .unauthorized, headers: ["Content-Type": "application/json"], body: JSONSerializer().serialize(json: json))
                }
            }
            return
        }

        next.respond(to: request, result: result)
    }
}
