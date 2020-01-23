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

struct UpdateOptions {
    let accessible: String?
    let accessControls: [String]?
    let authenticationPrompt: String?
}

struct ReadOptions {
    let authenticationPrompt: String?
}
