//
//  AuthRequestHeaders.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Alamofire
import Foundation

struct AuthRequestHeaders {
    let appName: String
    let language: String
    let isKidsApp: Bool
    let userType: String

    var httpHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Accept-Language": language,
            "userType": userType
        ]
        headers.add(name: "appName", value: appName)
        headers.add(name: "is-kids-app", value: String(isKidsApp))
        return headers
    }
}

extension AuthRequestHeaders {
    static let `default` = AuthRequestHeaders(
        appName: "moddakir",
        language: Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en",
        isKidsApp: false,
        userType: "User_S"
    )
}


