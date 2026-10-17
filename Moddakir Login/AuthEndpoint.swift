//
//  AuthEndpoint.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
enum AuthEndpoint {
    static let baseURL = URL(string: "https://revamp-auth-stage.moddakir.com")!

    case socialLogin
    case emailLogin

    var path: String {
        switch self {
        case .socialLogin:
            return "/api/auth/public/social-login"
        case .emailLogin:
            return "/api/auth/public/login"
        }
    }

    var url: URL {
        AuthEndpoint.baseURL.appendingPathComponent(path)
    }
}

