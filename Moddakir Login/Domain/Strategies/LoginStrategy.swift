//
//  LoginStrategy.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import UIKit

protocol LoginStrategy {
    func authenticate() async -> Either<AuthError, AuthResult>
}

final class LoginManager {
    func login(strategy: LoginStrategy) async -> Either<AuthError, AuthResult> {
        await strategy.authenticate()
    }
}
