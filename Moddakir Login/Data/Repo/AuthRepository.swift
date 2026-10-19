//
//  AuthRepository.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
protocol AuthRepository: AnyObject {
    func socialLogin(credentials: SocialLoginCredentials) async -> Either<AuthError, AuthResult>
    func emailLogin(email: String?, password: String) async -> Either<AuthError, AuthResult>
    func logout() async
    func currentUser() -> Consumer?
    func setCurrentUser(_ consumer: Consumer?)
}

