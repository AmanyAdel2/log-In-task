//
//  AuthMapperTests.swift
//  Moddakir Login
//
//  Created by Macos on 19/10/2026.
//

import XCTest
@testable import Moddakir_Login

final class AuthMapperTests: XCTestCase {
    func testConsumerMapper() {
        let dto = ConsumerDTO(
            id: "42", username: "user", gender: "male", email: "user@example.com",
            fullName: "Test User", phone: "123", avatarUrl: "https://example.com/a.png",
            country: "IQ", city: "Baghdad", address: nil, isRegistrationCompleted: true
        )

        let consumer = ConsumerMapper.map(dto)
        XCTAssertEqual(consumer.id, "42")
        XCTAssertEqual(consumer.displayName, "Test User")
        XCTAssertEqual(consumer.email, "user@example.com")
    }

    func testPendingMapper() {
        let dto = PendingSocialMediaAccountDTO(
            providerUserId: "abc", providerType: "google",
            accessToken: "token", missingFields: ["email", "phone"],
            socialMediaAccountPending: true
        )
        let pending = PendingSocialAccountMapper.map(dto)
        XCTAssertEqual(pending.providerType, "google")
        XCTAssertEqual(pending.missingFields, ["email", "phone"])
        XCTAssertTrue(pending.socialMediaAccountPending)
    }
}
