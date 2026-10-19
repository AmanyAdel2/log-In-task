//
//  MockAuthRepository.swift
//  Moddakir Login
//
//  Created by Macos on 19/10/2026.
//

import Combine
import XCTest
@testable import Moddakir_Login

final class MockAuthRepository: AuthRepository {
    var socialResult: Either<AuthError, AuthResult> = .left(.unknown("not configured"))
    var emailResult: Either<AuthError, AuthResult> = .left(.unknown("not configured"))

    func socialLogin(credentials: SocialLoginCredentials) async -> Either<AuthError, AuthResult> { socialResult }
    func emailLogin(email: String?, password: String) async -> Either<AuthError, AuthResult> { emailResult }
    func logout() async {}
    func currentUser() -> Consumer? { nil }
    func setCurrentUser(_ consumer: Consumer?) {}
}

@MainActor
final class LoginViewModelTests: XCTestCase {
    private let sampleConsumer = Consumer(
        id: "1", username: "john", fullName: "John Doe", email: "john@example.com",
        phone: nil, avatarUrl: nil, gender: nil, country: nil, city: nil, address: nil,
        isRegistrationCompleted: true
    )

    func testEmailLoginSuccess() async {
        let repository = MockAuthRepository()
        repository.emailResult = .right(.authenticated(sampleConsumer))

        let viewModel = LoginViewModel(
            loginManager: LoginManager(),
            emailLoginUseCase: EmailLoginUseCase(repository: repository),
            socialLoginUseCase: SocialLoginUseCase(repository: repository),
            onAuthenticated: { _ in },
            onPending: { _ in }
        )

        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.loginWithEmail()

        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(viewModel.state, .authenticated(sampleConsumer))
    }

    func testEmailLoginFailure() async {
        let repository = MockAuthRepository()
        repository.emailResult = .left(.network("Invalid credentials"))

        let viewModel = LoginViewModel(
            loginManager: LoginManager(),
            emailLoginUseCase: EmailLoginUseCase(repository: repository),
            socialLoginUseCase: SocialLoginUseCase(repository: repository),
            onAuthenticated: { _ in },
            onPending: { _ in }
        )

        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.loginWithEmail()

        try? await Task.sleep(nanoseconds: 200_000_000)
        if case .failed(let message) = viewModel.state {
            XCTAssertEqual(message, "Invalid credentials")
        } else {
            XCTFail("Expected failed state")
        }
    }
}

