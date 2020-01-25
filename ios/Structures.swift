//
//  Structures.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/22/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import Security

enum KeychainErrorCode: String, CaseIterable {
    case userCanceled = "USER_CANCELED"
    case noPassword = "NO_PASSWORD"
    case notAvailable = "NOT_AVAILABLE"
    case inputPasswordInvalid = "INPUT_PASSWORD_INVALID"
    case inputValueInvalid = "INPUT_VALUE_INVALID"
    case unexpectedPasswordData = "UNEXPECTED_PASSWORD_DATA"
    case unhandledException = "UNHANDLED_EXCEPTION"
}

enum KeychainError: Error, LocalizedError, CustomNSError {
    case noPassword
    case unexpectedPasswordData
    case invalidInputData(message: String)
    case unhandledError(status: OSStatus)

    static var errorDomain: String {
        return "in.thebase.KeychainQ"
    }

    var errorCode: Int {
        switch self {
        case .noPassword:
            return -131
        case .unexpectedPasswordData:
            return -132
        case .invalidInputData:
            return -133
        case .unhandledError(status: let status):
            return Int(status)
        }
    }

    var errorDescription: String? {
        switch self {
        case .noPassword:
            return "Password is not found."
        case .unexpectedPasswordData:
            return "Unexpected password data."
        case .invalidInputData(message: let message):
            return message
        case .unhandledError(status: let status):
            if #available(iOS 11.3, *) {
                return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
            } else {
                // Fallback on earlier versions
                return "Unhandled error \(status)"
            }
        }
    }
}

protocol Credentials {
    var account: String { get }
    var password: String { get }
}

struct InternetCredentials: Credentials, Encodable {
    enum CodingKeys: String, CodingKey {
        case server
        case port
        case account
        case password
    }

    let server: String
    let port: Int?
    let account: String
    let password: String

    init(item: Any) throws {
        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let account = existingItem[kSecAttrAccount as String] as? String,
            let server = existingItem[kSecAttrServer as String] as? String else {
                throw KeychainError.unexpectedPasswordData
        }
        self.server = server
        self.port = existingItem[kSecAttrPort as String] as? Int
        self.account = account
        self.password = password
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(server, forKey: .server)
        try container.encodeIfPresent(port, forKey: .port)
        try container.encode(account, forKey: .account)
        try container.encode(password, forKey: .password)
    }
}

struct SearchConditions {
    let accessGroup: String?
    let attributesOnly: Bool?
}

enum ConstantKeys: String, CodingKey {
    case authenticationUserCanceledCode
    case deviceOwnerAuthPolicy
}

struct AccountAttribute: RawRepresentable, ItemDecodable {
    enum ItemCodingKeys: String, CodingKey {
        case account
    }

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init?(item: Any) {
        guard let account = type(of: self).decodeStringIfPresent(item, for: .account) else { return nil }
        self.rawValue = account
    }
}

struct WriteAttributes: ItemDecodable {
    enum ItemCodingKeys: String, CodingKey {
        case accessible
        case accessControls
    }
    let accessible: String?
    let accessControls: [String]?

    init(item: Any) {
        self.accessible = type(of: self).decodeStringIfPresent(item, for: .accessible)
        self.accessControls = type(of: self).decodeStringArrayIfPresent(item, for: .accessControls)
    }
}

struct CommonAttributes: ItemDecodable {
    enum ItemCodingKeys: String, CodingKey {
        case accessGroup
        case authenticationPrompt
        case deviceOwnerAuthPolicy
    }
    let accessGroup: String?
    let authenticationPrompt: String?
    let deviceOwnerAuthPolicy: String?

    init(item: Any) {
        self.accessGroup = type(of: self).decodeStringIfPresent(item, for: .accessGroup)
        self.authenticationPrompt = type(of: self).decodeStringIfPresent(item, for: .authenticationPrompt)
        self.deviceOwnerAuthPolicy = type(of: self).decodeStringIfPresent(item, for: .deviceOwnerAuthPolicy)
    }
}

struct InternetPasswordQueryBuilder {
    private(set) var query: [String: Any]

    init(attributes: [String: Any] = [:]) {
        self.query = attributes.merging([kSecClass as String: kSecClassInternetPassword], uniquingKeysWith: { $1 })
    }
    init(serverString: String) throws {
        guard let url = parseURLString(serverString) else { throw KeychainError.invalidInputData(message: "input value `server` is not found") }
        self.query = [
            kSecClass as String: kSecClassInternetPassword,
        ]
        if let host = url.host {
            self.query[kSecAttrServer as String] = host
        }
        if let port = url.port {
            self.query[kSecAttrPort as String] = port
        }
    }

    func with(account: String) -> Self {
        return type(of: self).init(attributes: query.merging([kSecAttrAccount as String: account], uniquingKeysWith: { $1 }))
    }

    func with(commonAttributes: CommonAttributes) -> Self {
        var mQuery: [String: Any] = [:]
        if let accessGroup = commonAttributes.accessGroup {
            mQuery[kSecAttrAccessGroup as String] = accessGroup
        }
        if let authenticationPrompt = commonAttributes.authenticationPrompt {
            mQuery[kSecUseOperationPrompt as String] = authenticationPrompt
        }
        return type(of: self).init(attributes: query.merging(mQuery, uniquingKeysWith: { $1 }))
    }

    func with(key: String, value: Any) -> Self {
        return type(of: self).init(attributes: query.merging([key: value], uniquingKeysWith: { $1 }))
    }

    func with(attributes: [String: Any]) -> Self {
        return type(of: self).init(attributes: query.merging(attributes, uniquingKeysWith: { $1 }))
    }

    func with(account: String, attributes: WriteAttributes) throws -> Self {
        var mQuery: [String: Any] = [:]
        mQuery[kSecAttrAccount as String] = account
        var accessible: String?
        var accessControls: [AccessControlConstraints] = []
        if let rawValue = attributes.accessible, let typedAccessible = Accessible(rawValue: rawValue) {
            accessible = typedAccessible.dataValue
        }
        if let rawValues = attributes.accessControls {
            accessControls = rawValues.compactMap({ AccessControlConstraints(rawValue: $0) })
        }
        if accessControls.isEmpty {
            if let accessible = accessible {
                mQuery[kSecAttrAccessible as String] = accessible
            }
        } else {
            let flags = accessControls.reduce(into: SecAccessControlCreateFlags()) { result, constraint in
                let dataValue = constraint.dataValue
                guard !dataValue.isEmpty else { return }
                if result.isEmpty {
                    result.insert(dataValue)
                } else {
                    result.insert(.or)
                    result.insert(dataValue)
                }
            }
            let nonnullAccessible = accessible ?? kSecAttrAccessibleAfterFirstUnlock as String
            var error: Unmanaged<CFError>?
            let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, nonnullAccessible as CFString, flags, &error)
            if let error = error?.takeUnretainedValue() {
                throw error
            }
            mQuery[kSecAttrAccessControl as String] = access
        }
        return type(of: self).init(attributes: query.merging(mQuery, uniquingKeysWith: { $1 }))
    }
}

