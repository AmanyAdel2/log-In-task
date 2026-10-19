//
//  HomeViewModel.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var consumer: Consumer
    @Published var isLoggingOut: Bool = false

    private let logoutUseCase: LogoutUseCaseProtocol
    private let onLogout: () -> Void

    init(consumer: Consumer, logoutUseCase: LogoutUseCaseProtocol, onLogout: @escaping () -> Void) {
        self.consumer = consumer
        self.logoutUseCase = logoutUseCase
        self.onLogout = onLogout
    }

    func logout() {
        Task {
            isLoggingOut = true
            await logoutUseCase.execute()
            isLoggingOut = false
            onLogout()
        }
    }
}
