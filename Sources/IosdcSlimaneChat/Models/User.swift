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
    var avatarUrl: String

    var key: String {
      return "user:\(id)"
    }

    func serialize() -> String {
        // コンパイラのバグ?
        let json: JSON = [
            "name": "\(name)",
            "login": "\(id)",
            "avatar_url": "\(avatarUrl)"
        ]
        return JSONSerializer().serializeToString(json: json)
    }

    init(json: JSON) throws {
        guard let login = json["login"], let avatarUrl = json["avatar_url"] else {
            throw EntityError.unsatisfiedParameters
        }
        
        let id = try login.asString()

        self.id = id
        
        self.name = "foooooooo"
        
        do {
            if let name = json["name"] {
                self.name = try name.asString()
            }
        } catch {
            self.name = id
        }
        
        self.avatarUrl = try avatarUrl.asString()
    }
}
