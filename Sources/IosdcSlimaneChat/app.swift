import CLibUv
import Slimane
import BodyParser
import SessionMiddleware
import SwiftRedis
@_exported import Log

func errorHandler(_ error: Error) -> Response {
    let response: Response
    switch error {
    case RoutingError.routeNotFound:
        response = Response(status: .notFound, body: "\(error)")
    case StaticMiddlewareError.resourceNotFound:
        response = Response(status: .notFound, body: "\(error)")
    default:
        response = Response(status: .internalServerError, body: "\(error)")
    }
    return response
}

func launchApp() throws {
    let app = Slimane()
    
    app.errorHandler = errorHandler

    let redisPubConnection = try SwiftRedis.Connection(loop: uv_default_loop(), host: "127.0.0.1", port: 6379)
    let redisSubConnection = try SwiftRedis.Connection(loop: uv_default_loop(), host: "127.0.0.1", port: 6379)

    SlimaneIO.configure(redisPubConnection: redisPubConnection, redisSubConnection: redisSubConnection)

    app.use(Slimane.Static(root: "\(CommandLine.cwd)/public"))

    app.use(BodyParser.JSON())
    app.use(BodyParser.URLEncoded())

    app.use(SessionMiddleware(config: try sessionConfig()))

    app.use(ChatSocketMiddleware())

    app.use(AuthenticationMiddleware.parse)

    app.use { req, next, completion in
        print("[pid:\(CommandLine.pid)]\t\(Time())\t\(req.path ?? "/")")
        next.respond(to: req, result: completion)
    }

    // /auth
    app.get("/auth/github", handler: GithubAuthenticationRoute.doLogin)

    app.get("/auth/github/callback", handler: GithubAuthenticationRoute.callback)

    app.get("/chat/:roomName", [AuthenticationMiddleware()], handler: ChatRoute())

    app.get("/", handler: TopRoute())
    
    app.get("/foo") { req, responder in
        responder {
            Response(body: "OK")
        }
    }

    print("The server is listening at \(HOST):\(PORT)")
    try app.listen(host: HOST, port: PORT)
}
