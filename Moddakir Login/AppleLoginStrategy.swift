//
//  AppleLoginStrategy.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import AuthenticationServices
import UIKit

final class AppleLoginStrategy: NSObject, LoginStrategy {
    private let useCase: SocialLoginUseCaseProtocol
    private weak var presenting: UIViewController?

    private var continuation: CheckedContinuation<SocialLoginCredentials, Error>?

    init(useCase: SocialLoginUseCaseProtocol, presenting: UIViewController?) {
        self.useCase = useCase
        self.presenting = presenting
    }

    func authenticate() async -> Either<AuthError, AuthResult> {
        do {
            let credentials = try await requestAppleCredentials()
            return await useCase.execute(credentials: credentials)
        } catch {
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                return .left(.cancelled)
            }
            return .left(.socialProvider(error.localizedDescription))
        }
    }

    private func requestAppleCredentials() async throws -> SocialLoginCredentials {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleLoginStrategy: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.decoding)
            continuation = nil
            return
        }

        let formatter = PersonNameComponentsFormatter()
        let fullName = appleIDCredential.fullName.flatMap { formatter.string(from: $0) }

        let creds = SocialLoginCredentials(
            email: appleIDCredential.email,
            providerUserId: appleIDCredential.user,
            providerType: "Apple",
            phone: nil,
            fullName: fullName,
            gender: nil,
            country: nil,
            city: nil,
            address: nil,
            avatarUrl: nil,
            deviceUUID: UIDevice.current.identifierForVendor?.uuidString,
            idfa: nil
        )
        continuation?.resume(returning: creds)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleLoginStrategy: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presenting?.view.window ?? ASPresentationAnchor()
    }
}

