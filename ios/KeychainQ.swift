//
//  KeychainQ.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/22/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

@objc(KeychainQ)
class KeychainQ: NSObject {

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false;
    }
}

// MARK: - Public API
@objc extension KeychainQ {

    @objc(sampleMethod:numberParameter:callback:)
    func sampleMethod(stringArgument: String, numberParameter numberArgument: NSNumber, callback: RCTResponseSenderBlock) {
        callback(["numberArgument: \(numberArgument) stringArgument: \(stringArgument)"])
    }

    @objc
    func setInternetPassword(_ server: String, account: String, password: String, options: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    }

    @objc
    func searchInternetPasswords(_ server: String?, account: String?, conditions: [String: Any]?, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    }

    @objc
    func hasInternetPassword(_ server: String, account: String?, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    }

    @objc
    func findInternetPassword(_ server: String, account: String, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    }

    @objc
    func removeInternetPassword(_ server: String, account: String, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

    }

    @objc
    func resetInternetPasswords(_ server: String?, account: String?, resolver: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

    }
}
