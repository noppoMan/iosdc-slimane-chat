//
//  GithubUserRequest.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import Slimane
import JSON

struct GithubUserRequest: GithubApiClient {
    typealias Response = User

    let accessToken: String

    init(accessToken: String){
        self.accessToken = accessToken
    }

    var path: String {
        return "/user"
    }

    func buildResponse(response: S4.Response) throws -> Response {
        var response = response
        let json = try JSONParser().parse(data: response.body.becomeBuffer())
        return try User(json: json)
    }
}
