//
//  AuthRepositoryImpl.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let remote: AuthRemoteDataSource
    private let local: AuthLocalDataSource

    init(remote: AuthRemoteDataSource, local: AuthLocalDataSource) {
        self.remote = remote
        self.local = local
    }

    func socialLogin(credentials: SocialLoginCredentials) async -> Either<AuthError, AuthResult> {
        do {
            let response = try await remote.socialLogin(credentials: credentials, headers: .default)
            switch response.value {
            case .consumer(let dto):
                let consumer = ConsumerMapper.map(dto)
                local.saveCurrentUser(consumer)
                return .right(.authenticated(consumer))
            case .pending(let dto):
                let mapped = PendingSocialAccountMapper.map(dto)

                let pending = PendingSocialAccount(
                    providerUserId: mapped.providerUserId,
                    providerType: mapped.providerType,
                    accessToken: mapped.accessToken,
                    missingFields: mapped.missingFields,
                    socialMediaAccountPending: mapped.socialMediaAccountPending,
                    originalCredentials: credentials
                )
                return .right(.pending(pending))
            }
        } catch {
            return .left(.network(error.localizedDescription))
        }
    }

    func emailLogin(email: String?, password: String) async -> Either<AuthError, AuthResult> {
        do {
            let dto = try await remote.emailLogin(email: email, password: password, headers: .default)
            let consumer = ConsumerMapper.map(dto)
            local.saveCurrentUser(consumer)
            return .right(.authenticated(consumer))
        } catch {
            return .left(.network(error.localizedDescription))
        }
    }

    func logout() async {
        local.clear()
    }

    func currentUser() -> Consumer? {
        local.currentUser()
    }

    func setCurrentUser(_ consumer: Consumer?) {
        if let consumer {
            local.saveCurrentUser(consumer)
        } else {
            local.clear()
        }
    }
}
