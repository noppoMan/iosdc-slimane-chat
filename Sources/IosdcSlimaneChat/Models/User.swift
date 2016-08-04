//
//  User.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import JSON

struct User: Storeable {
    var id: String
    var name: String
    var email: String
    var avatarUrl: String

    var key: String {
      return "user:\(id)"
    }

    func serialize() -> String {
        // コンパイラのバグ?
        let json: JSON = [
            "name": "\(name)",
            "login": "\(id)",
            "email": "\(email)",
            "avatar_url": "\(avatarUrl)"
        ]
        return JSONSerializer().serializeToString(json: json)
    }

    init(json: JSON) throws {
        guard let name = json["name"], login = json["login"], email = json["email"], avatarUrl = json["avatar_url"] else {
            throw EntityError.unsatisfiedParameters
        }

        self.id = try login.asString()
        self.name = try name.asString()
        self.email = try email.asString()
        self.avatarUrl = try avatarUrl.asString()
    }
}
