//
//  ItemParser.swift
//  KeychainQ
//
//  Created by Satoshi Ohki on 1/23/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

func convertToString(value: Any?) -> String? {
    guard let value = value else { return nil }
    switch value {
    case is NSNull:
        return nil
    case let value as String:
        return value
    case let value as Bool:
        return value ? "1" : "0"
    default:
        return "\(value)"
    }
}

func convertToInt(value: Any?) -> Int? {
    guard let value = value else { return nil }
    if let value = value as? Int {
        return value
    }
    if let value = value as? NSNumber {
        return value.intValue
    }
    if let value = value as? String, !value.isEmpty {
        return Int(value)
    }
    return nil
}

func convertToBool(value: Any?) -> Bool? {
    guard let value = value else { return nil }
    if let value = convertToInt(value: value) {
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            return nil
        }
    }
    if let value = value as? Bool {
        return value
    }
    if let value = (value as? String)?.lowercased() {
        if ["false", "no"].contains(value) {
            return false
        }
        if ["true", "yes"].contains(value) {
            return true
        }
    }
    return nil
}

func parseURLString(_ urlString: String?) -> URL? {
    guard let urlString = urlString, let url = URL(string: urlString) else { return nil }
    if let host = url.host, !host.isEmpty {
        return url
    }
    if url.path.isEmpty {
        return nil
    }
    var urlComps = URLComponents()
    urlComps.host = url.path
    return urlComps.url
}

protocol ItemDecodable {
    associatedtype ItemCodingKeys: RawRepresentable & CodingKey
    static func decodeBoolIfPresent(_ item: Any, for key: ItemCodingKeys) -> Bool?
    static func decodeIntIfPresent(_ item: Any, for key: ItemCodingKeys) -> Int?
    static func decodeStringIfPresent(_ item: Any, for key: ItemCodingKeys) -> String?
    static func decodeStringArrayIfPresent(_ item: Any, for key: ItemCodingKeys) -> [String]?
    static func decodeIfPresent<T>(_ type: T.Type, item: Any, for key: ItemCodingKeys) -> T?
}

extension ItemDecodable where ItemCodingKeys.RawValue == String {

    static func decodeBoolIfPresent(_ item: Any, for key: ItemCodingKeys) -> Bool? {
        guard let item = item as? [String: Any] else { return nil }
        return convertToBool(value: item[key.rawValue])
    }

    static func decodeIntIfPresent(_ item: Any, for key: ItemCodingKeys) -> Int? {
        guard let item = item as? [String: Any] else { return nil }
        return convertToInt(value: item[key.rawValue])
    }

    static func decodeStringIfPresent(_ item: Any, for key: ItemCodingKeys) -> String? {
        guard let item = item as? [String: Any] else { return nil }
        return convertToString(value: item[key.rawValue])
    }

    static func decodeStringArrayIfPresent(_ item: Any, for key: ItemCodingKeys) -> [String]? {
        guard let item = item as? [String: Any] else { return nil }
        let value = item[key.rawValue]
        if let value = value as? [Any] {
            return value.compactMap { convertToString(value: $0) }
        } else if let value = convertToString(value: value) {
            return [value]
        }
        return nil
    }

    static func decodeIfPresent<T>(_ type: T.Type, item: Any, for key: ItemCodingKeys) -> T? {
        guard let item = item as? [String: Any] else { return nil }
        return item as? T
    }
}
