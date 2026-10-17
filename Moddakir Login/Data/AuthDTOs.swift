//
//  AuthDTOs.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
struct ConsumerSocialMediaLoginDTO: Encodable {
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

struct LoginDTO: Encodable {
    let email: String?
    let phone: String?
    let username: String?
    let password: String
}

struct ConsumerDTO: Decodable {
    let id: String?
    let username: String?
    let gender: String?
    let email: String?
    let fullName: String?
    let phone: String?
    let avatarUrl: String?
    let country: String?
    let city: String?
    let address: String?
    let isRegistrationCompleted: Bool?
}

struct PendingSocialMediaAccountDTO: Decodable {
    let providerUserId: String?
    let providerType: String?
    let accessToken: String?
    let missingFields: [String]?
    let socialMediaAccountPending: Bool?
}

struct ResponseErrorDTO: Decodable {
    let code: String?
    let message: String?
    let description: String?
}

struct SocialLoginData: Decodable {
    let accessToken: String?
    let consumer: ConsumerDTO?
    let providerUserId: String?
    let providerType: String?
    let missingFields: [String]?
    let socialMediaAccountPending: Bool?

    init(accessToken: String?,
         consumer: ConsumerDTO?,
         providerUserId: String?,
         providerType: String?,
         missingFields: [String]?,
         socialMediaAccountPending: Bool?) {
        self.accessToken = accessToken
        self.consumer = consumer
        self.providerUserId = providerUserId
        self.providerType = providerType
        self.missingFields = missingFields
        self.socialMediaAccountPending = socialMediaAccountPending
    }
}

struct SocialLoginResponseDTO: Decodable {
    enum Value {
        case consumer(ConsumerDTO)
        case pending(PendingSocialMediaAccountDTO)
    }
    let value: Value
    let data: SocialLoginData
    let accessToken: String?
    let status: String?
    let result: String?
    let error: ResponseErrorDTO?

    private enum RootKey: String, CodingKey {
        case data
        case status
        case result
        case error
        case accessToken
    }

    private enum DataKey: String, CodingKey {
        case accessToken
        case consumer
        case id
        case email
        case providerUserId
        case providerType
        case missingFields
        case socialMediaAccountPending
    }

    init(from decoder: Decoder) throws {
        let root = try? decoder.container(keyedBy: RootKey.self)

        let dataContainer: KeyedDecodingContainer<DataKey>
        var resolvedAccessToken: String?
        var resolvedStatus: String?
        var resolvedResult: String?
        var resolvedError: ResponseErrorDTO?

        if let root, root.contains(.data) {
            dataContainer = try root.nestedContainer(keyedBy: DataKey.self, forKey: .data)
            resolvedAccessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
            resolvedStatus = try root.decodeIfPresent(String.self, forKey: .status)
            resolvedResult = try root.decodeIfPresent(String.self, forKey: .result)
            resolvedError = try root.decodeIfPresent(ResponseErrorDTO.self, forKey: .error)
        } else {
            dataContainer = try decoder.container(keyedBy: DataKey.self)
            resolvedAccessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
            resolvedStatus = try root?.decodeIfPresent(String.self, forKey: .status)
            resolvedResult = try root?.decodeIfPresent(String.self, forKey: .result)
            resolvedError = try root?.decodeIfPresent(ResponseErrorDTO.self, forKey: .error)
        }

        let resolvedProviderUserId = try dataContainer.decodeIfPresent(String.self, forKey: .providerUserId)
        let resolvedProviderType = try dataContainer.decodeIfPresent(String.self, forKey: .providerType)
        let resolvedMissingFields = try dataContainer.decodeIfPresent([String].self, forKey: .missingFields)
        let resolvedSocialMediaAccountPending = try dataContainer.decodeIfPresent(Bool.self, forKey: .socialMediaAccountPending)

        let resolvedConsumer: ConsumerDTO?
        let resolvedPending: PendingSocialMediaAccountDTO?

        if dataContainer.contains(.consumer) {
            let consumer = try dataContainer.decode(ConsumerDTO.self, forKey: .consumer)
            resolvedConsumer = consumer
            resolvedPending = nil
            self.value = .consumer(consumer)
        } else if dataContainer.contains(.id) || dataContainer.contains(.email) {
            let consumer = try ConsumerDTO(from: dataContainer.superDecoder())
            resolvedConsumer = consumer
            resolvedPending = nil
            self.value = .consumer(consumer)
        } else {
            let pending = PendingSocialMediaAccountDTO(
                providerUserId: resolvedProviderUserId,
                providerType: resolvedProviderType,
                accessToken: try (resolvedAccessToken ?? dataContainer.decodeIfPresent(String.self, forKey: .accessToken)),
                missingFields: resolvedMissingFields,
                socialMediaAccountPending: resolvedSocialMediaAccountPending
            )
            resolvedConsumer = nil
            resolvedPending = pending
            self.value = .pending(pending)
        }

        let resolvedDataAccessToken: String?

        if let resolvedAccessToken {
            resolvedDataAccessToken = resolvedAccessToken
        } else {
            resolvedDataAccessToken = try dataContainer.decodeIfPresent(
                String.self,
                forKey: .accessToken
            )
        }
        self.data = SocialLoginData(
            accessToken: resolvedDataAccessToken,
            consumer: resolvedConsumer,
            providerUserId: resolvedPending?.providerUserId ?? resolvedProviderUserId,
            providerType: resolvedPending?.providerType ?? resolvedProviderType,
            missingFields: resolvedPending?.missingFields ?? resolvedMissingFields,
            socialMediaAccountPending: resolvedPending?.socialMediaAccountPending ?? resolvedSocialMediaAccountPending
        )

        self.accessToken = resolvedDataAccessToken
        self.status = resolvedStatus
        self.result = resolvedResult
        self.error = resolvedError
    }
}

struct EmailLoginResponseDTO: Decodable {
    let consumer: ConsumerDTO

    private enum RootKey: String, CodingKey {
        case data
        case consumer
        case id
        case email
    }

    private enum DataKey: String, CodingKey {
        case consumer
        case id
        case email
    }

    init(from decoder: Decoder) throws {
        let root = try? decoder.container(keyedBy: RootKey.self)

        if let root, root.contains(.data) {
            let dataContainer = try root.nestedContainer(keyedBy: DataKey.self, forKey: .data)
            if dataContainer.contains(.consumer) {
                self.consumer = try dataContainer.decode(ConsumerDTO.self, forKey: .consumer)
            } else {
                self.consumer = try ConsumerDTO(from: dataContainer.superDecoder())
            }
        } else if let root, root.contains(.consumer) {
            self.consumer = try root.decode(ConsumerDTO.self, forKey: .consumer)
        } else {
            self.consumer = try ConsumerDTO(from: decoder)
        }
    }
}
