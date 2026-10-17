//
//  DependencyContainer.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//


import Alamofire
import Foundation
import UIKit

final class DependencyContainer {
    private let apiClient: APIClient
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: AuthLocalDataSource
    private let repository: AuthRepository

    let loginManager: LoginManager
    let logoutUseCase: LogoutUseCase

    init() {
        self.apiClient = APIClient()
        self.remoteDataSource = AuthRemoteDataSourceImpl(client: apiClient)
        self.localDataSource = AuthLocalDataSourceImpl()
        self.repository = AuthRepositoryImpl(remote: remoteDataSource, local: localDataSource)

        self.loginManager = LoginManager()
        self.logoutUseCase = LogoutUseCase(repository: repository)
    }

    func makeSocialLoginUseCase() -> SocialLoginUseCaseProtocol {
        SocialLoginUseCase(repository: repository)
    }

    func makeEmailLoginUseCase() -> EmailLoginUseCaseProtocol {
        EmailLoginUseCase(repository: repository)
    }

    @MainActor func makeLoginViewModel(onAuthenticated: @escaping (Consumer) -> Void,
                            onPending: @escaping (PendingSocialAccount) -> Void) -> LoginViewModel {
        LoginViewModel(
            loginManager: loginManager,
            emailLoginUseCase: makeEmailLoginUseCase(),
            socialLoginUseCase: makeSocialLoginUseCase(),
            onAuthenticated: onAuthenticated,
            onPending: onPending
        )
    }

    @MainActor func makeHomeViewModel(consumer: Consumer, onLogout: @escaping () -> Void) -> HomeViewModel {
        HomeViewModel(consumer: consumer, logoutUseCase: logoutUseCase, onLogout: onLogout)
    }

    func currentUser() -> Consumer? {
        repository.currentUser()
    }
}

