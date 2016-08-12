//
//  GithubAuthenticationRoute.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import Slimane
import Thrush
import Render
import MustacheViewEngine

struct GithubAuthenticationRoute {

    static func doLogin(to request: Request, responder: @escaping ((Void) throws -> Response) -> Void){
        responder {
            Response(redirect: "https://github.com/login/oauth/authorize?scope=user:email,public_repo&client_id=\(GITHUB_CLIENT_ID)")
        }
    }

    static func callback(to request: Request, responder: @escaping ((Void) throws -> Response) -> Void){
        guard let code = request.uri.singleValuedQuery["code"] else {
            return responder { throw GithubAPIError.codeRequired }
        }

        let params = Parameter.formData([
            "client_id": GITHUB_CLIENT_ID,
            "client_secret": GITHUB_CLIENT_SECRET,
            "code": code,
            "redirect_uri": "\(APP_BASE_URL)/auth/github/callback"
        ])

        var request = request

        GithubAccessTokenRequest(params: params)
            .send()
            .then { (accessToken: AccessToken) -> Promise<User> in
                request.session?["access_token"] = accessToken.token
                return GithubUserRequest(accessToken: accessToken.token).send()
            }
            .then { (user: User) -> Promise<User> in
              return user.save()
            }
            .then { user in
                request.login(user) {
                    responder {
                        Response(redirect: "/")
                    }
                }
            }
            .`catch` { error in
                print("\(error): \(error.localizedDescription)")
                responder {
                    Response(status: .badRequest, body: "\(error)")
                }
            }
    }
}
