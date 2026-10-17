//
//  AppleLoginStrategy.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import Foundation
import AuthenticationServices
import UIKit

@MainActor
final class AppleLoginStrategy: NSObject, LoginStrategy {

    private let useCase: SocialLoginUseCaseProtocol
    private weak var presenting: UIViewController?

    private var continuation:
        CheckedContinuation<SocialLoginCredentials, Error>?

    private var authorizationController: ASAuthorizationController?

    init(
        useCase: SocialLoginUseCaseProtocol,
        presenting: UIViewController?
    ) {
        self.useCase = useCase
        self.presenting = presenting
        super.init()
    }

    func authenticate() async -> Either<AuthError, AuthResult> {

        guard presenting?.viewIfLoaded?.window != nil else {
            return .left(
                .socialProvider(
                    "The presentation window is not available."
                )
            )
        }

        do {
            let credentials = try await requestAppleCredentials()
            return await useCase.execute(credentials: credentials)

        } catch {
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                return .left(.cancelled)
            }

            return .left(
                .socialProvider(error.localizedDescription)
            )
        }
    }

    private func requestAppleCredentials()
        async throws -> SocialLoginCredentials {

        try await withCheckedThrowingContinuation { continuation in

            self.continuation = continuation

            let request =
                ASAuthorizationAppleIDProvider().createRequest()

            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(
                authorizationRequests: [request]
            )

            controller.delegate = self
            controller.presentationContextProvider = self

            self.authorizationController = controller
            controller.performRequests()
        }
    }

    private func finish(
        with result: Result<SocialLoginCredentials, Error>
    ) {
        guard let continuation else { return }

        self.continuation = nil
        self.authorizationController = nil

        continuation.resume(with: result)
    }
}

extension AppleLoginStrategy: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential =
                authorization.credential as? ASAuthorizationAppleIDCredential
        else {
            finish(with: .failure(AuthError.decoding))
            return
        }

        let formatter = PersonNameComponentsFormatter()
        let fullName = credential.fullName.flatMap {
            formatter.string(from: $0)
        }

        let credentials = SocialLoginCredentials(
            email: credential.email,
            providerUserId: credential.user,
            providerType: "Apple",
            phone: nil,
            fullName: fullName,
            gender: nil,
            country: nil,
            city: nil,
            address: nil,
            avatarUrl: nil,
            deviceUUID: UIDevice.current
                .identifierForVendor?.uuidString,
            idfa: nil
        )

        finish(with: .success(credentials))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        finish(with: .failure(error))
    }
}

extension AppleLoginStrategy:
    ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {

        guard let window = presenting?.viewIfLoaded?.window else {
            assertionFailure("Apple Sign-In window is unavailable.")
            return ASPresentationAnchor()
        }

        return window
    }
}
