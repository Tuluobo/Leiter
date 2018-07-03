//
//  Proxy.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import NEKit
import WCDBSwift

extension CryptoAlgorithm: ColumnCodable {
    
    static let allValues: [CryptoAlgorithm] = [.AES128CFB, .AES192CFB, .AES256CFB, .CHACHA20, .SALSA20, .RC4MD5]
    
    public static var columnType: ColumnType {
        return .text
    }
    
    public init?(with value: FundamentalValue) {
        self.init(rawValue: value.stringValue)
    }
    
    public func archivedValue() -> FundamentalValue {
        return FundamentalValue(self.rawValue)
    }
}

enum ProxyType: String, ColumnCodable {
    case http = "Http"
    case socks5 = "Socks5"
    case shadowsocks = "Shadowsocks"
    
    static var columnType: ColumnType {
        return .text
    }
    
    init?(with scheme: String) {
        switch scheme {
        case "proxy":
            self = .http
        case "socks5":
            self = .socks5
        case "ss":
            self = .shadowsocks
        default:
            return nil
        }
    }
    
    var scheme: String {
        switch self {
        case .http:
            return "proxy"
        case .socks5:
            return "socks5"
        case .shadowsocks:
            return "ss"
        }
    }
    
    init?(with value: FundamentalValue) {
        self.init(rawValue: value.stringValue)
    }
    
    func archivedValue() -> FundamentalValue {
        return FundamentalValue(self.rawValue)
    }
}

enum ProxyMode: String, ColumnCodable {
    case general = "general"
    case all = "all"
    
    static var columnType: ColumnType {
        return .text
    }
    
    init?(with value: FundamentalValue) {
        self.init(rawValue: value.stringValue)
    }
    
    func archivedValue() -> FundamentalValue {
        return FundamentalValue(self.rawValue)
    }
}

// MARK: - Proxy Model

struct Proxy: BaseModel {
    
    var rid: Int?
    var type: ProxyType = .http
    var identifier: String?
    var server: String = ""
    var port: Int = 0
    var mode: ProxyMode = .general
    
    // http(s)
    var isHttps: Bool = false
    var isVerfiy: Bool = false
    // SS
    var encryption: CryptoAlgorithm?
    var password: String?
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Proxy
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case rid
        case type
        case identifier
        case server
        case port
        case mode
        case isHttps
        case isVerfiy
        case encryption
        case password
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                rid: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true)
            ]
        }
    }
}
