//
//  ApiClient.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import Slimane
import Thrush
import JSON

enum Parameter {
    case json(JSON)
    case formData([String: String])
    case queryString([String: [String?]])
    case raw(String)
}

enum ApiClientError: ErrorProtocol {
    case hostRequired
}

protocol ApiClient {
    associatedtype Response

    var scheme: String { get }

    var host: String { get }

    var path: String { get }

    var method: S4.Method { get }

    var parameters: Parameter { get }

    var headers: [CaseInsensitiveString: String] { get }

    func buildResponse(response: S4.Response) throws -> Response
}

extension ApiClient {

    var scheme: String {
        return "https"
    }

    var method: S4.Method {
        return .get
    }

    var headers: [CaseInsensitiveString: String] {
        return [:]
    }

    var parameters: Parameter {
        return .raw("")
    }

    func send() -> Promise<Response> {
        return Promise { resolve, reject in
            let body: Data
            var uri = URI(path: self.path)

            switch self.parameters {
            case .json(let json):
                body = JSONSerializer().serializeToString(json: json).data
            case .formData(let params):
                body = params.map({ k, v in "\(k)=\(v)" }).joined(separator: "&").data
            case .queryString(let query):
                uri.query = query
                body = []
            case .raw(let string):
                body = string.data
            }

            do {
                let client = try HTTPSClient(host: self.host)
                client.write(method: self.method, uri: uri, headers: self.headers, body: body).then { response in
                    do {
                        resolve(try self.buildResponse(response: response))
                    } catch {
                        reject(error)
                    }
                }
            } catch {
                reject(error)
            }
        }
    }
}
