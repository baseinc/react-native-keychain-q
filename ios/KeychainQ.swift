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
    func constantsToExport() -> [AnyHashable: Any]! {
        return constants.reduce(into: [AnyHashable: Any]()) { result, item in
            result[item.key.rawValue] = item.value
        }
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}

// MARK: - Public Bridging API
@objc extension KeychainQ {

    @objc
    func fetchSupportedBiometryType(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            let biometryType = try supportedBiometryType()
            resolver(biometryType)
        } catch {
            rejecter(rejectErrorCode(.notAvailable), error.localizedDescription, error)
        }
    }

    @objc
    func saveInternetPassword(_ server: String, account: String, password: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try save(server: server, account: account, password: password, options: options ?? [:])
            resolver(true)
        } catch {
            switch error {
            case KeychainError.noPassword:
                rejecter(rejectErrorCode(.inputPasswordInvalid), error.localizedDescription, error)
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            case KeychainError.unhandledError(status: let status) where status == errSecUserCanceled:
                rejecter(rejectErrorCode(.userCanceled), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }

    @objc
    func removeInternetPassword(_ server: String, account: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try remove(server: server, account: account, options: options ?? [:])
            resolver(true)
        } catch {
            switch error {
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }

    @objc
    func containsAnyInternetPassword(_ server: String, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            resolver(try contains(server: server, options: options))
        } catch {
            switch error {
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
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
            switch error {
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            case KeychainError.unexpectedPasswordData, EncodingError.invalidValue:
                rejecter(rejectErrorCode(.unexpectedPasswordData), error.localizedDescription, error)
            case KeychainError.unhandledError(status: let status) where status == errSecUserCanceled:
                rejecter(rejectErrorCode(.userCanceled), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }

    @objc
    func resetInternetPasswords(_ server: String?, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try reset(server: server, options: options)
            resolver(true)
        } catch {
            switch error {
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }

    @objc
    func retrieveInternetPasswords(_ server: String?, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            let collection = try retrieve(server: server, options: options)
            let encoder = JSONEncoder()
            let array = collection.compactMap({ try? encoder.encode($0) }).compactMap({ try? JSONSerialization.jsonObject(with: $0, options: [.allowFragments])})
            resolver(array)
        } catch {
            switch error {
            case KeychainError.invalidInputData:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            case KeychainError.unexpectedPasswordData, EncodingError.invalidValue:
                rejecter(rejectErrorCode(.unexpectedPasswordData), error.localizedDescription, error)
            case KeychainError.unhandledError(status: let status) where status == errSecUserCanceled:
                rejecter(rejectErrorCode(.userCanceled), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }
}

extension KeychainQ {

    func matchingInternetPasswordQueryBuilder(server: String?, options: Any) throws -> InternetPasswordQueryBuilder {
        let commonAttrs = CommonAttributes(item: options)
        if let server = server {
            return try InternetPasswordQueryBuilder(serverString: server)
                .with(commonAttributes: commonAttrs)
        }
        return InternetPasswordQueryBuilder()
            .with(commonAttributes: commonAttrs)
    }
}

extension KeychainQ {

    func rejectErrorCode(_ code: KeychainErrorCode) -> String {
        return code.rawValue
    }

    var constants: [ConstantKeys: Any] {
        return [
            // To handling when user canceled on authentication prompt.
            .authenticationUserCanceledCode: Int(errSecUserCanceled),
        ]
    }

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

    func save(server: String, account: String, password: String, options: Any) throws {
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

    func reset(server: String?, options: Any) throws {
        let query = try matchingInternetPasswordQueryBuilder(server: server, options: options).query
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

    func get(server: String, options: Any) throws -> InternetCredentials? {
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
            return try InternetCredentials(item: result)
        case errSecItemNotFound:
            return nil
        default:
            break
        }
        throw KeychainError.unhandledError(status: status)
    }

    func retrieve(server: String?, options: Any) throws -> [InternetCredentials] {
        var queryBuilder = try matchingInternetPasswordQueryBuilder(server: server, options: options)
            .with(attributes: [
                kSecMatchLimit as String: kSecMatchLimitAll,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true
            ])
        if let account = AccountAttribute(item: options) {
            queryBuilder = queryBuilder.with(account: account.rawValue)
        }
        let query = queryBuilder.query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            guard let result = result as? [Any] else { throw KeychainError.unexpectedPasswordData }
            return result.compactMap({ try? InternetCredentials(item: $0) })
        case errSecItemNotFound:
            return []
        default:
            break
        }
        throw KeychainError.unhandledError(status: status)
    }
}
