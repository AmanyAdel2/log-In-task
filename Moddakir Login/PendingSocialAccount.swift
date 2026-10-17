//
//  PendingSocialAccount.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
struct PendingSocialAccount: Equatable {
    let providerUserId: String
    let providerType: String
    let accessToken: String?
    let missingFields: [String]
    let socialMediaAccountPending: Bool
}

