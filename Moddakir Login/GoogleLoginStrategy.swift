//
//  GoogleLoginStrategy.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import Foundation
import UIKit
import GoogleSignIn

final class GoogleLoginStrategy: LoginStrategy {

    private let useCase: SocialLoginUseCaseProtocol
    private weak var presenting: UIViewController?

    init(
        useCase: SocialLoginUseCaseProtocol,
        presenting: UIViewController?
    ) {
        self.useCase = useCase
        self.presenting = presenting
    }

    func authenticate() async -> Either<AuthError, AuthResult> {

        guard let presenting = presenting else {
            return .left(
                .socialProvider("Missing presentation controller.")
            )
        }

        do {
            let credentials: SocialLoginCredentials =
                try await withCheckedThrowingContinuation {
                    (continuation: CheckedContinuation<SocialLoginCredentials, Error>) in

                    GIDSignIn.sharedInstance.signIn(
                        withPresenting: presenting
                    ) { result, error in

                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }

                        guard let user = result?.user,
                              let userID = user.userID else {
                            continuation.resume(
                                throwing: AuthError.socialProvider(
                                    "Google user information is missing."
                                )
                            )
                            return
                        }

                        let credentials = SocialLoginCredentials(
                            email: user.profile?.email,
                            providerUserId: userID,
                            providerType: "Google",
                            phone: nil,
                            fullName: user.profile?.name,
                            gender: nil,
                            country: nil,
                            city: nil,
                            address: nil,
                            avatarUrl: user.profile?
                                .imageURL(withDimension: 200)?
                                .absoluteString,
                            deviceUUID: UIDevice.current
                                .identifierForVendor?.uuidString,
                            idfa: nil
                        )

                        continuation.resume(returning: credentials)
                    }
                }

            return await useCase.execute(
                credentials: credentials
            )

        } catch {
            return .left(
                .socialProvider(error.localizedDescription)
            )
        }
    }
}
