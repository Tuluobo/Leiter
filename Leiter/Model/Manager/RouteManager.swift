//
//  RouteManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift
import WCDBSwift
import NEKit

class RouteManager {
    static let shared = RouteManager()
    private init() { }
    

    func all() -> [Route] {
        do {
            let routes: [Route] = try (DatabaseManager.shared.database?.getObjects(on: Route.Properties.all, fromTable: Route.tableName)) ?? []
            return routes
        } catch {
            DDLogError("Route Select All Error: \(error.localizedDescription)")
            return []
        }
    }
    
    func delete(_ route: Route) -> Bool {
        do {
            guard let rid = route.rid else {
                return false
            }
            try DatabaseManager.shared.database?.delete(fromTable: Route.tableName, where: Route.Properties.rid == rid)
            return true
        } catch {
            DDLogError("Route[\(route.server):\(route.port)]: delete Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func save(route: Route) -> Bool {
        do {
            try DatabaseManager.shared.database?.insertOrReplace(objects: route, intoTable: Route.tableName)
            return true
        } catch {
            DDLogError("Route[\(route.server):\(route.port)]: insert Error: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - QRCode
    func saveQRcode(with qrString: String?) -> Bool {
        guard let route = decodeQRCode(with: qrString) else {
            return false
        }
        return save(route: route)
    }
    
    // cmM0LW1kNTptc3gxMjM0NTZAc3MudHVsdW9iby5jb206ODA4MD9SZW1hcms9TGlub2RlLVZQUyZPVEE9ZmFsc2U
    func decodeQRCode(with qrString: String?) -> Route? {
        guard let qr = qrString, let url = URL(string: qr) else { return nil }
        guard let scheme = url.scheme, let base64Str = url.host else { return nil }
        // 修正
        var fixBase64Str = base64Str
        if fixBase64Str.count % 2 != 0 {
            fixBase64Str += "="
        }
        // Data
        guard let data = Data(base64Encoded: fixBase64Str),
            let dataStr = String(data: data, encoding: String.Encoding.utf8),
            let encodeUrl = URL(string: scheme + "://" + dataStr),
            let host = encodeUrl.host, let port = encodeUrl.port, let type = RouteType(with: scheme) else {
            return nil
        }
        
        var route = Route()
        route.type = type
        route.server = host
        route.port = port
        route.password = encodeUrl.password
        if let user = encodeUrl.user?.uppercased() {
            guard let encryption = CryptoAlgorithm(rawValue: user) else { return nil }
            route.encryption = encryption
        }
        if let query = encodeUrl.query {
            for pair in query.components(separatedBy: "&") {
                let keyValues = pair.components(separatedBy: "=")
                guard keyValues.count == 2, let key = keyValues.first, let value = keyValues.last?.replacingOccurrences(of: "+", with: " ") else {
                    continue
                }
                if key == "Remark" {
                    route.identifier = value
                }
            }
        }
        return route
    }
    
    // ss://rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
    func encodeQRCode(with route: Route) -> String? {
        var dataStr = ""
        switch route.type {
        case .http: break
        case .socks5: break
        case .shadowsocks:
            dataStr = "ss://\((route.encryption ?? .AES256CFB).rawValue):\(route.password ?? "")@\(route.server):\(route.port)"
            if let remark = route.identifier {
                dataStr += "?Remark=\(remark)"
            }
        }
        
        guard let encodeData = dataStr.data(using: String.Encoding.utf8)?.base64EncodedString() else {
            return nil
        }
        return route.type.scheme + "://" + encodeData
    }
}
