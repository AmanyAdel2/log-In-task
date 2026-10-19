//
//  LoginviewModel.swift
//  Moddakir Login
//
//  Created by Macos on 19/10/2026.
//

import Combine
import Foundation
import UIKit

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    @Published var email: String = ""
    @Published var password: String = ""

    private let loginManager: LoginManager
    private let emailUseCase: EmailLoginUseCaseProtocol
    private let socialUseCase: SocialLoginUseCaseProtocol
    private let onAuthenticated: (Consumer) -> Void
    private let onPending: (PendingSocialAccount) -> Void

    init(
        loginManager: LoginManager,
        emailLoginUseCase: EmailLoginUseCaseProtocol,
        socialLoginUseCase: SocialLoginUseCaseProtocol,
        onAuthenticated: @escaping (Consumer) -> Void,
        onPending: @escaping (PendingSocialAccount) -> Void
    ) {
        self.loginManager = loginManager
        self.emailUseCase = emailLoginUseCase
        self.socialUseCase = socialLoginUseCase
        self.onAuthenticated = onAuthenticated
        self.onPending = onPending
    }
    func loginWithEmail() {
        Task { await performLogin(strategy: EmailLoginStrategy(email: email, password: password, useCase: emailUseCase)) }
    }

    func loginWithGoogle(presenting: UIViewController?) {
        Task {
            let strategy = GoogleLoginStrategy(useCase: socialUseCase, presenting: presenting)
            await performLogin(strategy: strategy)
        }
    }

    func loginWithApple(presenting: UIViewController?) {
        print("🍎 [3] LoginViewModel started")

        Task { @MainActor in
            let strategy = AppleLoginStrategy(
                useCase: socialUseCase,
                presenting: presenting
            )

            print("🍎 [4] AppleLoginStrategy created")

            await performLogin(strategy: strategy)

            print("🍎 [7] Apple login flow finished")
        }
    }

    private func performLogin(strategy: LoginStrategy) async {
        state = .loading
        let result = await loginManager.login(strategy: strategy)
        switch result {
        case .right(.authenticated(let consumer)):
            state = .authenticated(consumer)
            onAuthenticated(consumer)
        case .right(.pending(let pending)):
            state = .pending(pending)
            onPending(pending)
        case .left(let error):
            print("❌ [LoginViewModel] Login failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }
}



import Combine
import Foundation

enum LoginViewState: Equatable {
    case idle
    case loading
    case authenticated(Consumer)
    case pending(PendingSocialAccount)
    case failed(String)

    static func == (lhs: LoginViewState, rhs: LoginViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.authenticated(let a), .authenticated(let b)):
            return a == b
        case (.pending(let a), .pending(let b)):
            return a == b
        case (.failed(let a), .failed(let b)):
            return a == b
        default:
            return false
        }
    }
}

