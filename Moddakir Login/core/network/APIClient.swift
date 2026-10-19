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

        #if DEBUG
        print("🌐 Endpoint: \(endpoint.path)")
        print("📡 HTTP Status: \(response.response?.statusCode ?? -1)")

        if let data = response.data,
           let json = try? JSONSerialization.jsonObject(
               with: data,
               options: [.fragmentsAllowed]
           ) {
            let safeJSON = Self.redactingSensitiveValues(json)

            if let safeData = try? JSONSerialization.data(
                withJSONObject: safeJSON,
                options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed]
            ), let text = String(data: safeData, encoding: .utf8) {
                print("📦 Response JSON (sensitive values redacted):\n\(text)")
            }
        }
        #endif

        switch response.result {
        case .success(let value):
            return value

        case .failure(let error):
            throw error
        }
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    private static func redactingSensitiveValues(_ value: Any) -> Any {
        let sensitiveKeys: Set<String> = [
            "accesstoken",
            "refreshtoken",
            "token",
            "email",
            "phone",
            "fullname",
            "username",
            "address",
            "avatarurl",
            "provideruserid",
            "deviceuuid",
            "idfa",
            "id",
            "gender"
        ]

        if let dictionary = value as? [String: Any] {
            var result: [String: Any] = [:]

            for (key, value) in dictionary {
                let normalizedKey = key
                    .lowercased()
                    .replacingOccurrences(of: "_", with: "")

                if sensitiveKeys.contains(normalizedKey) {
                    result[key] = "<REDACTED>"
                } else {
                    result[key] = redactingSensitiveValues(value)
                }
            }

            return result
        }

        if let array = value as? [Any] {
            return array.map { redactingSensitiveValues($0) }
        }

        return value
    }
}
