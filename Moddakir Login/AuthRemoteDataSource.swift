//
//  AuthRemoteDataSource.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import Foundation

protocol AuthRemoteDataSource: AnyObject {
    func socialLogin(credentials: SocialLoginCredentials, headers: AuthRequestHeaders) async throws -> SocialLoginResponseDTO
    func emailLogin(email: String?, password: String, headers: AuthRequestHeaders) async throws -> ConsumerDTO
}

final class AuthRemoteDataSourceImpl: AuthRemoteDataSource {
    private let client: APIClient
    private let headers: AuthRequestHeaders

    init(client: APIClient, headers: AuthRequestHeaders = .default) {
        self.client = client
        self.headers = headers
    }

    func socialLogin(credentials: SocialLoginCredentials, headers: AuthRequestHeaders) async throws -> SocialLoginResponseDTO {
        let dto = SocialLoginCredentialsMapper.map(credentials)
        return try await client.request(
            endpoint: .socialLogin,
            body: dto,
            headers: headers.httpHeaders
        )
    }

    func emailLogin(email: String?, password: String, headers: AuthRequestHeaders) async throws -> ConsumerDTO {
        let dto = LoginDTO(email: email, phone: nil, username: nil, password: password)
        let response: EmailLoginResponseDTO = try await client.request(
            endpoint: .emailLogin,
            body: dto,
            headers: headers.httpHeaders
        )
        return response.consumer
    }
}

