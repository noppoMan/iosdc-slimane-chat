import SessionRedisStore

func sessionConfig() throws -> SessionConfig {
    switch SLIMANE_ENV {
    case .production:
        return SessionConfig(
            secret: "aa4f0b4429960862cbaccba163b81d9bd4c06938",
            expires: 3600,
            store: try RedisStore(loop: Loop.defaultLoop, host: "127.0.0.1", port: 6379),
            path: "/"
        )
    default:
        return SessionConfig(
            secret: "aa4f0b4429960862cbaccba163b81d9bd4c06934",
            expires: 3600,
            store: try RedisStore(loop: Loop.defaultLoop, host: "127.0.0.1", port: 6379),
            path: "/"
        )
    }
}
