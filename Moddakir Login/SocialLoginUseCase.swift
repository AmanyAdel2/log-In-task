//
//  SocialLoginUseCase.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
protocol SocialLoginUseCaseProtocol {
    func execute(credentials: SocialLoginCredentials) async -> Either<AuthError, AuthResult>
}

final class SocialLoginUseCase: SocialLoginUseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(credentials: SocialLoginCredentials) async -> Either<AuthError, AuthResult> {
        await repository.socialLogin(credentials: credentials)
    }
}

protocol EmailLoginUseCaseProtocol {
    func execute(email: String?, password: String) async -> Either<AuthError, AuthResult>
}

final class EmailLoginUseCase: EmailLoginUseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String?, password: String) async -> Either<AuthError, AuthResult> {
        await repository.emailLogin(email: email, password: password)
    }
}

protocol LogoutUseCaseProtocol {
    func execute() async
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async {
        await repository.logout()
    }
}


