//
//  AccessTokenRequest.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import Slimane
import JSON

struct GithubAccessTokenRequest: ApiClient {
    typealias Response = AccessToken

    let params: Parameter

    init(params: Parameter){
        self.params = params
    }

    var method: S4.Method {
        return .post
    }

    var host: String {
        return GITHUB_AUTH_HOST
    }

    var path: String {
        return "/login/oauth/access_token"
    }

    var headers: [CaseInsensitiveString: String] {
        return ["Accept": "application/json"]
    }

    var parameters: Parameter {
        return params
    }

    func buildResponse(response: S4.Response) throws -> Response {
        var response = response
        let json = try JSONParser().parse(data: response.body.becomeBuffer())

        guard let token = json["access_token"], scope = json["scope"], type = json["token_type"] else {
            throw GithubAPIError.noToken
        }

        return try AccessToken(token: token.asString(), scope: scope.asString(), type: type.asString())
    }
}
