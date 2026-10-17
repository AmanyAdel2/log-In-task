//
//  APIClient.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import Alamofire
import Foundation

final class APIClient {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable, Body: Encodable>(
        endpoint: AuthEndpoint,
        method: HTTPMethod = .post,
        body: Body?,
        headers: HTTPHeaders
    ) async throws -> T {
        let request = session
            .request(endpoint.url, method: method, parameters: body, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()

        let response = await request.serializingDecodable(T.self).response
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
