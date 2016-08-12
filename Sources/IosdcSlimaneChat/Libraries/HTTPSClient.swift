//
//  HTTPSClient.swift
//  IosdcSlimaneChat
//
//  Created by Yuki Takei on 8/5/16.
//
//

import SecureHanger
import Thrush

final class HTTPSClient {
    
    let connection: SecureClientConnection
    
    init(host: String, port: Int = 443) throws {
        self.connection = try SecureClientConnection(host: host, port: port)
    }
    
    func write(method: S4.Method = .get, path: String = "/", headers: [CaseInsensitiveString: String] = [:], body: Data = []) -> Promise<Response> {
        return write(method: method, uri: URI(path: path), headers: headers, body: body)
    }
    
    func write(method: S4.Method = .get, uri: URI, headers: [CaseInsensitiveString: String] = [:], body: Data = []) -> Promise<Response> {
        return Promise<Response> { [unowned self] resolve, reject in
            let request = Request(method: method, uri: uri, headers: Headers(headers), body: body)
            
            do {
                _ = try SecureHanger(connection: self.connection, request: request) { getResponse in
                    do {
                        resolve(try getResponse())
                    } catch {
                        reject(error)
                    }
                }
            } catch {
                reject(error)
            }
        }
    }
    
    func close() throws {
        try self.connection.close()
    }
    
}
