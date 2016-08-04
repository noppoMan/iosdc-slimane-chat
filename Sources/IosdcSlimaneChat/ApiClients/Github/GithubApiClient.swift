//
//  GithubApiClient.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import Slimane

protocol GithubApiClient: ApiClient {
    var accessToken: String { get }
}

extension GithubApiClient {
    var host: String {
        return GITHUB_API_HOST
    }

    var headers: [CaseInsensitiveString: String] {
        return [
            "Accept": "application/json",
            "Authorization": "token \(accessToken)"
        ]
    }
}
