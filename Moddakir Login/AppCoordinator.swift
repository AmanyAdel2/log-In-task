//
//  AppCoordinator.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import UIKit
final class AppCoordinator {
    private let window: UIWindow
    private let container: DependencyContainer
    private var currentViewController: UIViewController?

    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }

    @MainActor func start() {
        if let user = container.currentUser() {
            showHome(user: user)
        } else {
            showLogin()
        }
    }

    @MainActor func showLogin() {
        let viewModel = container.makeLoginViewModel(
            onAuthenticated: { [weak self] user in
                self?.showHome(user: user)
            },
            onPending: { [weak self] pending in
                print("Pending social account: \(pending)")
                self?.showLogin()
            }
        )
        let viewController = LoginViewController(viewModel: viewModel)
        setRoot(viewController)
    }

    @MainActor func showHome(user: Consumer) {
        let viewModel = container.makeHomeViewModel(consumer: user, onLogout: { [weak self] in
            self?.showLogin()
        })
        let viewController = HomeViewController(viewModel: viewModel)
        setRoot(viewController)
    }

    private func setRoot(_ viewController: UIViewController) {
        currentViewController = viewController
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
