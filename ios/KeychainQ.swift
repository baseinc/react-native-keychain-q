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
class KeychainQ: NSObject {}

// MARK: - Public Bridging API
@objc extension KeychainQ {

    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    func constantsToExport() -> [AnyHashable: Any]! {
        return constants.reduce(into: [AnyHashable: Any]()) { result, item in
            result[item.key.rawValue] = item.value
        }
    }

    func fetchCanUseDeviceAuthPolicy(_ rawValue: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            let result = try canUseDeviceAuthPolicy(rawValue: rawValue)
            resolver(result)
        } catch {
            rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
        }
    }

    func fetchSupportedBiometryType(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        resolver(supportedBiometryType())
    }

    func saveInternetPassword(_ server: String, account: String, password: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            try save(server: server, account: account, password: password, options: options ?? [:])
            resolver(true)
        } catch {
            switch error {
            case KeychainError.noPassword:
                rejecter(rejectErrorCode(.inputPasswordInvalid), error.localizedDescription, error)
            case KeychainError.invalidInputData, KeychainError.policyCannotBeEvaluated:
                rejecter(rejectErrorCode(.inputValueInvalid), error.localizedDescription, error)
            case KeychainError.unhandledError(status: let status) where status == errSecUserCanceled:
                rejecter(rejectErrorCode(.userCanceled), error.localizedDescription, error)
            default:
                rejecter(rejectErrorCode(.unhandledException), error.localizedDescription, error)
            }
        }
    }

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

    func findInternetPassword(_ server: String, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            guard let credentials = try get(server: server, options: options) else {
                return resolver(nil)
            }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
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

    func retrieveInternetPasswords(_ server: String?, options: [String: Any], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        do {
            let collection = try retrieve(server: server, options: options)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let array = collection.compactMap { try? encoder.encode($0) }.compactMap { try? JSONSerialization.jsonObject(with: $0, options: [.allowFragments]) }
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
        let commonAttrs = try CommonAttributes(item: options)
        if let server = server {
            return try InternetPasswordQueryBuilder(serverString: server)
                .with(commonAttributes: commonAttrs)
        }
        return InternetPasswordQueryBuilder()
            .with(commonAttributes: commonAttrs)
    }

    func canUseAuthPolicy(context: LAContext, policy: LAPolicy) -> (Bool, Error?) {
        var error: NSError?
        let canBeprotected = context.canEvaluatePolicy(policy, error: &error)
        return (canBeprotected, error)
    }

    func validateDeviceAuthPolicy(policy: LAPolicy) throws {
        let context = LAContext()
        let (canBeProtected, error) = canUseAuthPolicy(context: context, policy: policy)
        guard canBeProtected, error == nil else {
            if let error = error {
                throw error
            }
            throw KeychainError.policyCannotBeEvaluated
        }
    }
}

extension KeychainQ {

    func rejectErrorCode(_ code: KeychainErrorCode) -> String {
        return code.rawValue
    }

    var constants: [ExternConstantKeys: Any] {
        return [
            // To handling when user canceled on authentication prompt.
            .authenticationUserCanceledCode: Int(errSecUserCanceled),
            .keychainErrorCodes: KeychainErrorCode.allRawKeyValues,
        ]
    }

    func canUseDeviceAuthPolicy(rawValue: String) throws -> Bool {
        guard let policy = DeviceOwnerAuthPolicy(rawValue: rawValue), let laPolicy = policy.dataValue else { throw KeychainError.invalidInputData(message: formatInvalidConstantDataMessage(field: "\(InternalConstantKeys.deviceOwnerAuthPolicy)", value: rawValue, category: "one", correctValue: "\(DeviceOwnerAuthPolicy.validRawValues.joined(separator: ", "))"))
        }
        let context = LAContext()
        let (canBeProtected, error) = canUseAuthPolicy(context: context, policy: laPolicy)
        if error == nil && canBeProtected {
            return true
        }
        return false
    }

    func supportedBiometryType() -> String {
        let context = LAContext()
        let (canBeProtected, error) = canUseAuthPolicy(context: context, policy: .deviceOwnerAuthentication)
        if error == nil && canBeProtected {
            if #available(iOS 11.0, *) {
                return BiometryTypeLabel(biometryType: context.biometryType).rawValue
            }
            return BiometryTypeLabel.touchID.rawValue
        }
        return BiometryTypeLabel.none.rawValue
    }

    func save(server: String, account: String, password: String, options: Any) throws {
        guard let passwordData = password.data(using: .utf8) else { throw KeychainError.unexpectedPasswordData }
        let commontAttrs = try CommonAttributes(item: options)
        // Pre-check policy evaluation
        if let inputPolicy = commontAttrs.deviceOwnerAuthPolicy, let policy = inputPolicy.dataValue {
            try validateDeviceAuthPolicy(policy: policy)
        }
        let writeAttrs = try WriteAttributes(item: options)
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
        let a = ["aaa", "bbb"]
        let b = a[10]
        let commonAttrs = try CommonAttributes(item: options)
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
        let account = AccountAttribute(item: options)
        var queryBuilder = try matchingInternetPasswordQueryBuilder(server: server, options: options)
            .with(attributes: [
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true,
            ])
        if let account = account {
            queryBuilder = queryBuilder.with(account: account.rawValue)
        }
        var result: AnyObject?
        let status = SecItemCopyMatching(queryBuilder.query as CFDictionary, &result)
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
            return result.compactMap { try? InternetCredentials(item: $0) }
        case errSecItemNotFound:
            return []
        default:
            break
        }
        throw KeychainError.unhandledError(status: status)
    }
}
