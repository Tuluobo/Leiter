//
//  ProxyManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift
import WCDBSwift
import NEKit

class ProxyManager {
    static let shared = ProxyManager()
    private init() { }
    

    func all() -> [Proxy] {
        do {
            let proxies: [Proxy] = try (DatabaseManager.shared.database?.getObjects(on: Proxy.Properties.all, fromTable: Proxy.tableName)) ?? []
            return proxies
        } catch {
            DDLogError("Proxy Select All Error: \(error.localizedDescription)")
            return []
        }
    }
    
    func delete(_ proxy: Proxy) -> Bool {
        do {
            guard let rid = proxy.rid else {
                return false
            }
            try DatabaseManager.shared.database?.delete(fromTable: Proxy.tableName, where: Proxy.Properties.rid == rid)
            return true
        } catch {
            DDLogError("Proxy[\(proxy.server):\(proxy.port)]: delete Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func save(proxy: Proxy) -> Bool {
        do {
            try DatabaseManager.shared.database?.insertOrReplace(objects: proxy, intoTable: Proxy.tableName)
            return true
        } catch {
            DDLogError("Proxy[\(proxy.server):\(proxy.port)]: insert Error: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - QRCode
    func saveQRcode(with qrString: String?) -> Bool {
        guard let proxy = decodeQRCode(with: qrString) else {
            return false
        }
        return save(proxy: proxy)
    }
    
    // cmM0LW1kNTptc3gxMjM0NTZAc3MudHVsdW9iby5jb206ODA4MD9SZW1hcms9TGlub2RlLVZQUyZPVEE9ZmFsc2U
    func decodeQRCode(with qrString: String?) -> Proxy? {
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
            let host = encodeUrl.host, let port = encodeUrl.port, let type = ProxyType(with: scheme) else {
            return nil
        }
        
        var proxy = Proxy()
        proxy.type = type
        proxy.server = host
        proxy.port = port
        proxy.password = encodeUrl.password
        if let user = encodeUrl.user?.uppercased() {
            guard let encryption = CryptoAlgorithm(rawValue: user) else { return nil }
            proxy.encryption = encryption
        }
        if let query = encodeUrl.query {
            for pair in query.components(separatedBy: "&") {
                let keyValues = pair.components(separatedBy: "=")
                guard keyValues.count == 2, let key = keyValues.first, let value = keyValues.last?.replacingOccurrences(of: "+", with: " ") else {
                    continue
                }
                if key == "Remark" {
                    proxy.identifier = value
                }
            }
        }
        return proxy
    }
    
    // ss://rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
    func encodeQRCode(with proxy: Proxy) -> String? {
        var dataStr = ""
        switch proxy.type {
        case .http: break
        case .socks5: break
        case .shadowsocks:
            dataStr = "ss://\((proxy.encryption ?? .AES256CFB).rawValue):\(proxy.password ?? "")@\(proxy.server):\(proxy.port)"
            if let remark = proxy.identifier {
                dataStr += "?Remark=\(remark)"
            }
        }
        
        guard let encodeData = dataStr.data(using: String.Encoding.utf8)?.base64EncodedString() else {
            return nil
        }
        return proxy.type.scheme + "://" + encodeData
    }
}
