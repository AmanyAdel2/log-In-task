//
//  SocialLoginCredentials.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
struct SocialLoginCredentials : Equatable{
    let email: String?
    let providerUserId: String
    let providerType: String
    let phone: String?
    let fullName: String?
    let gender: String?
    let country: String?
    let city: String?
    let address: String?
    let avatarUrl: String?
    let deviceUUID: String?
    let idfa: String?
}

extension SocialLoginCredentials {
    func completingRegistration(
        phone: String,
        gender: String
    ) -> SocialLoginCredentials {
        SocialLoginCredentials(
            email: email,
            providerUserId: providerUserId,
            providerType: providerType,
            phone: phone,
            fullName: fullName,
            gender: gender,
            country: country,
            city: city,
            address: address,
            avatarUrl: avatarUrl,
            deviceUUID: deviceUUID,
            idfa: idfa
        )
    }
}

//extension SocialLoginCredentials {
//    func completingRegistration(phone: String, gender: String) -> SocialLoginCredentials {
//        SocialLoginCredentials(
//            email: email,
//            providerUserId: providerUserId,
//            providerType: providerType,
//            phone: phone,
//            fullName: fullName,
//            gender: gender,
//            country: country,
//            city: city,
//            address: address,
//            avatarUrl: avatarUrl,
//            deviceUUID: deviceUUID,
//            idfa: idfa
//        )
//    }
//}

