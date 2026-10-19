//
//  AuthLocalDataSource.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
protocol AuthLocalDataSource: AnyObject {
    func saveCurrentUser(_ consumer: Consumer)
    func currentUser() -> Consumer?
    func clear()
}

final class AuthLocalDataSourceImpl: AuthLocalDataSource {
    private let userDefaults: UserDefaults
    private let userKey = "current_user"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveCurrentUser(_ consumer: Consumer) {
        if let data = try? JSONEncoder().encode(consumer) {
            userDefaults.set(data, forKey: userKey)
        }
    }

    func currentUser() -> Consumer? {
        guard let data = userDefaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(Consumer.self, from: data)
    }

    func clear() {
        userDefaults.removeObject(forKey: userKey)
    }
}
