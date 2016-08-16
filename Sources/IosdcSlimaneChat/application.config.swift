//
//  application.config.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

enum Environment: String {
    case production = "production"
    case development = "development"
}

var PORT: Int {
    guard let portString = CommandLine.env["PORT"], let port = Int(portString) else {
        return 3000
    }
    return port
}

let HOST = CommandLine.env["HOST"] ?? "0.0.0.0"

let SLIMANE_ENV = Environment(rawValue: CommandLine.env["SLIMANE_ENV"] ?? "development") ?? .development

let GITHUB_CLIENT_ID = "d0a56933d5439775e999"

let GITHUB_CLIENT_SECRET = "7d373f622c55a6839609b96cc93870455bf6c271"

let APP_BASE_URL = "http://localhost:\(PORT)"

let GITHUB_API_HOST = "api.github.com"

let GITHUB_AUTH_HOST = "github.com"

