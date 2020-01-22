//
//  Structures.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/22/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

struct Credentials {
    let account: String
    let password: String

    init(item: Any) throws {
        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let account = existingItem[kSecAttrAccount as String] as? String else {
                throw KeychainError.unexpectedPasswordData
        }
        self.account = account
        self.password = password
    }
}

struct SearchConditions {
    let accessGroup: String?
    let attributesOnly: Bool?
}

/// Input parameter keys from React Native
enum InputAttributeKeys: String, CodingKey {
    case accessGroup
    case service
    case authenticationPrompt
    case accessible
}

/// - Note: Reference [Accessibility Values](https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_attribute_keys_and_values)
enum Accessible: String, CaseIterable {
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case whenUnlocked
    case afterFirstUnlockThisDeviceOnly
    case afterFirstUnlock

    var dataValue: String {
        switch self {
        case .whenPasscodeSetThisDeviceOnly:
            return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        case .whenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .whenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
        case .afterFirstUnlockThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .afterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
        }
    }
}

/// - Note: Reference [SecAccessControlCreateFlags](https://developer.apple.com/documentation/security/secaccesscontrolcreateflags)
enum AccessControlConstraints: String, CaseIterable {
    case devicePasscode
    case biometryAny
    case biometryCurrentSet
    case userPresence
    case applicationPassword

    var dataValue: SecAccessControlCreateFlags {
        switch self {
        case .devicePasscode:
            return .devicePasscode
        case .biometryAny:
            return .biometryAny
        case .biometryCurrentSet:
            return .biometryCurrentSet
        case .userPresence:
            return .userPresence
        case .applicationPassword:
            return .applicationPassword
        }
    }
}
