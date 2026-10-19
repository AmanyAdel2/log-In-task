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
    let originalCredentials: SocialLoginCredentials?

    init(
        providerUserId: String,
        providerType: String,
        accessToken: String?,
        missingFields: [String],
        socialMediaAccountPending: Bool,
        originalCredentials: SocialLoginCredentials? = nil
    ) {
        self.providerUserId = providerUserId
        self.providerType = providerType
        self.accessToken = accessToken
        self.missingFields = missingFields
        self.socialMediaAccountPending = socialMediaAccountPending
        self.originalCredentials = originalCredentials
    }
}
