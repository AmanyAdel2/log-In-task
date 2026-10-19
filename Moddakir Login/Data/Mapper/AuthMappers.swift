//
//  AuthMappers.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
enum ConsumerMapper {
    static func map(_ dto: ConsumerDTO) -> Consumer {
        Consumer(
            id: dto.id ?? "",
            username: dto.username,
            fullName: dto.fullName,
            email: dto.email,
            phone: dto.phone,
            avatarUrl: dto.avatarUrl,
            gender: dto.gender,
            country: dto.country,
            city: dto.city,
            address: dto.address,
            isRegistrationCompleted: dto.isRegistrationCompleted
        )
    }
}

enum PendingSocialAccountMapper {
    static func map(_ dto: PendingSocialMediaAccountDTO) -> PendingSocialAccount {
        PendingSocialAccount(
            providerUserId: dto.providerUserId ?? "",
            providerType: dto.providerType ?? "",
            accessToken: dto.accessToken,
            missingFields: dto.missingFields ?? [],
            socialMediaAccountPending: dto.socialMediaAccountPending ?? true
        )
    }
}

enum SocialLoginCredentialsMapper {
    static func map(_ credentials: SocialLoginCredentials) -> ConsumerSocialMediaLoginDTO {
        ConsumerSocialMediaLoginDTO(
            email: credentials.email,
            providerUserId: credentials.providerUserId,
            providerType: credentials.providerType,
            phone: credentials.phone,
            fullName: credentials.fullName,
            gender: credentials.gender,
            country: credentials.country,
            city: credentials.city,
            address: credentials.address,
            avatarUrl: credentials.avatarUrl,
            deviceUUID: credentials.deviceUUID,
            idfa: credentials.idfa
        )
    }
}

