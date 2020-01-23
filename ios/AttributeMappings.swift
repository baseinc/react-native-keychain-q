//
//  AttributeMappings.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/23/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

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
enum AccessControlConstraints: String {
    case devicePasscode
    @available(iOS 11.3, *)
    case biometryAny
    @available(iOS 11.3, *)
    case biometryCurrentSet
    case userPresence
    case applicationPassword

    var dataValue: SecAccessControlCreateFlags {
        switch self {
        case .devicePasscode:
            return .devicePasscode
        case .biometryAny:
            if #available(iOS 11.3, *) {
                return .biometryAny
            } else {
                // Fallback on earlier versions
                return []
            }
        case .biometryCurrentSet:
            if #available(iOS 11.3, *) {
                return .biometryCurrentSet
            } else {
                // Fallback on earlier versions
                return []
            }
        case .userPresence:
            return .userPresence
        case .applicationPassword:
            return .applicationPassword
        }
    }
}

enum BiometryTypeLabel: String, CaseIterable {
    case touchID
    case faceID
    case none

    @available(iOS 11.0, *)
    init(biometryType: LABiometryType) {
        switch biometryType {
        case .touchID:
            self = .touchID
        case .faceID:
            self = .faceID
        default:
            self = .none
        }
    }
}
