//
//  Consumer.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
struct Consumer: Identifiable, Equatable, Codable {
    let id: String
    let username: String?
    let fullName: String?
    let email: String?
    let phone: String?
    let avatarUrl: String?
    let gender: String?
    let country: String?
    let city: String?
    let address: String?
    let isRegistrationCompleted: Bool?

    var displayName: String {
        if let fullName, !fullName.isEmpty { return fullName }
        if let username, !username.isEmpty { return username }
        if let email, !email.isEmpty { return email }
        return "User"
    }
}
