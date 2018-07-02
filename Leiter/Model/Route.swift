//
//  Route.swift
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

enum RouteType: String, ColumnCodable {
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

enum RouteMode: Int, ColumnCodable {
    case split = 0
    case full
    
    static var columnType: ColumnType {
        return .integer32
    }
    
    init?(with value: FundamentalValue) {
        self.init(rawValue: Int(value.int32Value))
    }
    
    func archivedValue() -> FundamentalValue {
        return FundamentalValue(self.rawValue)
    }
}

//MARK: - Route

struct Route: BaseModel {
    
    var rid: Int?
    var type: RouteType = .http
    var identifier: String?
    var server: String = ""
    var port: Int = 0
    var mode: RouteMode = .split
    
    // http(s)
    var isHttps: Bool = false
    var isVerfiy: Bool = false
    // SS
    var encryption: CryptoAlgorithm?
    var password: String?
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Route
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
