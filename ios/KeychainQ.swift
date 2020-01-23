//
//  KeychainQ.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/22/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

@objc(KeychainQ)
class KeychainQ: NSObject {

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}

// MARK: - Public Bridging API
@objc extension KeychainQ {

    @objc(sampleMethod:numberParameter:callback:)
    func sampleMethod(stringArgument: String, numberParameter numberArgument: NSNumber, callback: RCTResponseSenderBlock) {
        callback(["numberArgument: \(numberArgument) stringArgument: \(stringArgument)"])
    }

    @objc
    func fetchSupportedBiometryType(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            let biometryType = try supportedBiometryType()
            resolver(biometryType)
        } catch {
            rejecter(#function, error.localizedDescription, error)
        }
    }

    @objc
    func setInternetPassword(_ server: String, account: String, password: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try set(server: server, account: account, password: password, options: options ?? [:])
            resolver(true)
        } catch {
            rejecter(#function, error.localizedDescription, error)
        }
    }

    @objc
    func removeInternetPassword(_ server: String, account: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try remove(server: server, account: account, options: options ?? [:])
            resolver(true)
        } catch {
            rejecter(#function, error.localizedDescription, error)
        }
    }

    @objc
    func containsAnyInternetPassword(_ server: String, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            resolver(try contains(server: server, options: options))
        } catch {
            rejecter(#function, error.localizedDescription, error)
        }
    }

    @objc
    func findInternetPassword(_ server: String, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            guard let credentials = try get(server: server, options: options) else {
                return resolver(nil)
            }
            let encoder = JSONEncoder()
            let data = try encoder.encode(credentials)
            let dict = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            resolver(dict)
        } catch {
            rejecter(#function, error.localizedDescription, error)
        }
    }

    @objc
    func resetInternetPasswords(_ server: String?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        resolver(true)
    }

    @objc
    func searchInternetPasswords(_ server: String?, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        resolver(true)
    }
}

extension KeychainQ {

    func matchingInternetPasswordQueryBuilder(server: String, options: Any) throws -> InternetPasswordQueryBuilder {
        let commonAttrs = CommonAttributes(item: options)
        return try InternetPasswordQueryBuilder(serverString: server)
            .with(commonAttributes: commonAttrs)
            .with(key: kSecMatchLimit as String, value: kSecMatchLimitOne)
    }
}

extension KeychainQ {

    func supportedBiometryType() throws -> String {
        let context = LAContext()
        var error: NSError?
        let canBeProtected = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if error == nil && canBeProtected {
            if #available(iOS 11.0, *) {
                return BiometryTypeLabel(biometryType: context.biometryType).rawValue
            }
            return BiometryTypeLabel.touchID.rawValue
        }
        if let error = error {
            throw error
        }
        return BiometryTypeLabel.none.rawValue
    }

    func set(server: String, account: String, password: String, options: Any) throws {
        guard let passwordData = password.data(using: .utf8) else { throw KeychainError.unexpectedPasswordData }
        let commontAttrs = CommonAttributes(item: options)
        let writeAttrs = WriteAttributes(item: options)
        let queryBuilder = try InternetPasswordQueryBuilder(serverString: server)
            .with(commonAttributes: commontAttrs)
        let readQuery = queryBuilder
            .with(account: account)
            .with(key: kSecUseAuthenticationUI as String, value: kSecUseAuthenticationUIFail)
            .query

        let readStatus = SecItemCopyMatching(readQuery as CFDictionary, nil)
        if readStatus == errSecSuccess || readStatus == errSecInteractionNotAllowed {
            try remove(server: server, account: account, options: options)
        }
        let query = try queryBuilder
            .with(account: account, attributes: writeAttrs)
            .with(key: kSecValueData as String, value: passwordData)
            .query
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func remove(server: String, account: String, options: Any) throws {
        let commonAttrs = CommonAttributes(item: options)
        let query = try InternetPasswordQueryBuilder(serverString: server)
            .with(commonAttributes: commonAttrs)
            .with(account: account)
            .query
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func contains(server: String, options: Any) throws -> Bool {
        let account = AccountAttribute(item: options)
        var queryBuilder = try matchingInternetPasswordQueryBuilder(server: server, options: options)
            .with(attributes: [
                kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ])
        if let account = account {
            queryBuilder = queryBuilder.with(account: account.rawValue)
        }
        let status = SecItemCopyMatching(queryBuilder.query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainError.unhandledError(status: status)
        }
    }

    func get(server: String, options: Any) throws -> Credentials? {
        guard let account = AccountAttribute(item: options) else { throw KeychainError.invalidInputData(message: "input value `account` is not found")}
        let query = try matchingInternetPasswordQueryBuilder(server: server, options: options)
            .with(account: account.rawValue)
            .with(attributes: [
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true,
            ])
            .query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let result = result else { throw KeychainError.unexpectedPasswordData }
            return try Credentials(item: result)
        case errSecItemNotFound:
            return nil
        default:
            break
        }
        throw KeychainError.unhandledError(status: status)
    }
}
