//
//  AuthResult.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
import Foundation

enum AuthResult {
    case authenticated(Consumer)
    case pending(PendingSocialAccount)
}

