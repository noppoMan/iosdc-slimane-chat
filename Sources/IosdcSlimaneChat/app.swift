import CLibUv
import Slimane
import BodyParser
import SessionMiddleware
import SwiftRedis
@_exported import Log

func launchApp() throws {
    let app = Slimane()

    let redisPubConnection = try SwiftRedis.Connection(loop: uv_default_loop(), host: "127.0.0.1", port: 6379)
    let redisSubConnection = try SwiftRedis.Connection(loop: uv_default_loop(), host: "127.0.0.1", port: 6379)

    SlimaneIO.configure(redisPubConnection: redisPubConnection, redisSubConnection: redisSubConnection)

    app.use(Slimane.Static(root: "\(Process.cwd)/public"))

    app.use(BodyParser())

    app.use(SessionMiddleware(conf: try sessionConfig()))

    app.use(ChatSocketMiddleware())

    app.use(AuthenticationMiddleware.parse)

    app.use { req, next, completion in
        print("[pid:\(Process.pid)]\t\(Time())\t\(req.path ?? "/")")
        next.respond(to: req, result: completion)
    }

    // /auth
    app.get("/auth/github", handler: GithubAuthenticationRoute.doLogin)

    app.get("/auth/github/callback", handler: GithubAuthenticationRoute.callback)

    app.get("/chat/:roomName", [AuthenticationMiddleware()], handler: ChatRoute())

    app.get("/", handler: TopRoute())

    print("The server is listening at \(HOST):\(PORT)")
    try app.listen(host: HOST, port: PORT)
}
