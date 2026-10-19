//
//  AuthError.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
enum AuthError: Error, LocalizedError, Equatable {
    case invalidEmail
    case invalidPassword
    case missingFields([String])
    case pendingAccount(PendingSocialAccount)
    case notAuthenticated
    case cancelled
    case socialProvider(String)
    case network(String)
    case decoding
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email."
        case .invalidPassword:
            return "Password must be at least 8 characters."
        case .missingFields(let fields):
            return "Please complete: " + fields.joined(separator: ", ")
        case .pendingAccount:
            return "Additional information is required to finish registration."
        case .notAuthenticated:
            return "You are not logged in."
        case .cancelled:
            return "Sign in was cancelled."
        case .socialProvider(let message):
            return message
        case .network(let message):
            return message
        case .decoding:
            return "Could not read the server response."
        case .unknown(let message):
            return message
        }
    }
}


