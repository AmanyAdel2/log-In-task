//
//  EmailLoginStrategy.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
final class EmailLoginStrategy: LoginStrategy {
    private let email: String?
    private let password: String
    private let useCase: EmailLoginUseCaseProtocol

    init(email: String?, password: String, useCase: EmailLoginUseCaseProtocol) {
        self.email = email
        self.password = password
        self.useCase = useCase
    }

    func authenticate() async -> Either<AuthError, AuthResult> {
        if let email, !email.isEmpty {
            let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.contains("@") { return .left(.invalidEmail) }
        }
        if password.count < 8 { return .left(.invalidPassword) }
        return await useCase.execute(email: email, password: password)
    }
}
