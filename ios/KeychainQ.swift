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

    @objc(sampleMethod:numberParameter:callback:)
    func sampleMethod(stringArgument: String, numberParameter numberArgument: NSNumber, callback: RCTResponseSenderBlock) {
        callback(["numberArgument: \(numberArgument) stringArgument: \(stringArgument)"])
    }
}

