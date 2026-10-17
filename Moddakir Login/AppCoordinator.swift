//
//  AppCoordinator.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import Foundation
import UIKit

@MainActor
final class AppCoordinator {

    private let window: UIWindow
    private let container: DependencyContainer

    private var currentViewController: UIViewController?

    private weak var completeRegistrationViewController:
        CompleteRegistrationViewController?

    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }

    // MARK: - Start

    func start() {
        if let user = container.currentUser() {
            showHome(user: user)
        } else {
            showLogin()
        }
    }

    // MARK: - Login

    func showLogin() {
        let viewModel = container.makeLoginViewModel(
            onAuthenticated: { [weak self] user in
                self?.showHome(user: user)
            },
            onPending: { [weak self] pending in
                self?.showCompleteRegistration(pending: pending)
            }
        )

        let viewController = LoginViewController(
            viewModel: viewModel
        )

        completeRegistrationViewController = nil
        setRoot(viewController)
    }

    // MARK: - Complete Registration

    func showCompleteRegistration(
        pending: PendingSocialAccount
    ) {
        let viewController = CompleteRegistrationViewController(
            pending: pending,
            onSubmit: { [weak self] phone, gender in

                guard let self else { return }

                guard let originalCredentials =
                        pending.originalCredentials else {

                    self.completeRegistrationViewController?
                        .setSubmitting(false)

                    self.completeRegistrationViewController?
                        .showSubmissionError(
                            "The original social login information is missing. Please sign in again."
                        )

                    return
                }

                // Preserve the original Google/Apple credentials
                // and add the information entered by the user.
                let credentials =
                    originalCredentials.completingRegistration(
                        phone: phone,
                        gender: gender
                    )

                let useCase =
                    self.container.makeSocialLoginUseCase()

                Task { @MainActor [weak self] in
                    guard let self else { return }

                    let result = await useCase.execute(
                        credentials: credentials
                    )

                    switch result {

                    // MARK: Authentication completed successfully

                    case .right(.authenticated(let consumer)):
                        print("Registration completed successfully.")

                        self.completeRegistrationViewController = nil
                        self.showHome(user: consumer)

                    // MARK: Server returned Pending

                    case .right(.pending(let nextPending)):
                        print("Registration is still pending.")
                        print(
                            "Missing fields: \(nextPending.missingFields)"
                        )
                        print(
                            "Pending flag: \(nextPending.socialMediaAccountPending)"
                        )

                        // If the server reports no missing fields,
                        // display Home using the available local profile.
                        if nextPending.missingFields.isEmpty {

                            let trimmedName = credentials.fullName?
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )

                            let emailPrefix = credentials.email?
                                .components(separatedBy: "@")
                                .first

                            let displayName =
                                (trimmedName?.isEmpty == false
                                    ? trimmedName
                                    : nil)
                                ?? emailPrefix
                                ?? "User"

                            let consumer = Consumer(
                                id: "",
                                username: displayName,
                                fullName: displayName,
                                email: credentials.email,
                                phone: credentials.phone,
                                avatarUrl: credentials.avatarUrl,
                                gender: credentials.gender,
                                country: credentials.country,
                                city: credentials.city,
                                address: credentials.address,
                                isRegistrationCompleted: nil
                            )

                            print(
                                "Opening Home with the available profile data."
                            )

                            self.completeRegistrationViewController = nil
                            self.showHome(user: consumer)

                        } else {
                            // Keep the current screen if fields remain missing.
                            self.completeRegistrationViewController?
                                .setSubmitting(false)

                            let message = """
                            Registration is not complete yet.

                            Missing fields: \(nextPending.missingFields.joined(separator: ", "))
                            """

                            self.completeRegistrationViewController?
                                .showSubmissionError(message)
                        }

                    // MARK: Request failed

                    case .left(let error):
                        print(
                            "Registration request failed: \(error.localizedDescription)"
                        )

                        self.completeRegistrationViewController?
                            .setSubmitting(false)

                        self.completeRegistrationViewController?
                            .showSubmissionError(
                                error.localizedDescription
                            )
                    }
                }
            }
        )

        completeRegistrationViewController = viewController
        setRoot(viewController)
    }

    // MARK: - Home

    func showHome(user: Consumer) {
        let viewModel = container.makeHomeViewModel(
            consumer: user,
            onLogout: { [weak self] in
                self?.showLogin()
            }
        )

        let viewController = HomeViewController(
            viewModel: viewModel
        )

        setRoot(viewController)
    }

    // MARK: - Root Navigation

    private func setRoot(_ viewController: UIViewController) {
        currentViewController = viewController
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
