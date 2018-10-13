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

let kProxyOldValueKey = "kProxyOldValueKey"
let kProxyNewValueKey = "kProxyNewValueKey"

private let kSelectedProxyKey = "kSelectedProxyKey"

class ProxyManager {
    
    var currentProxy: Proxy? {
        didSet {
            guard let proxy = currentProxy, let rid = proxy.rid  else {
                return
            }
            UserDefaults.standard.set(rid, forKey: kSelectedProxyKey)
            NotificationCenter.default.post(name: Notification.Name.CurrentProxyChangeNotification,
                                            object: nil,
                                            userInfo: [kProxyOldValueKey: oldValue as Any, kProxyNewValueKey: proxy])
        }
    }
    
    static let shared = ProxyManager()
    private init() {
        setupCurrentProxy()
    }

    func all() -> [Proxy] {
        do {
            let proxies: [Proxy] = try DatabaseManager.shared.database?.getObjects(on: Proxy.Properties.all, fromTable: Proxy.tableName, orderBy: [Proxy.Properties.rid.asOrder(by: .descending)]) ?? []
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
            NotificationCenter.default.post(name: Notification.Name.AddProxySuccessNotification, object: nil, userInfo: ["proxy": proxy])
            if let current = currentProxy, current.rid == proxy.rid {
                currentProxy = proxy
            }
            // 默认选择一个
            setupCurrentProxy()
            return true
        } catch {
            DDLogError("Proxy[\(proxy.server):\(proxy.port)]: insert Error: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private
    private func setupCurrentProxy() {
        if currentProxy == nil {
            let allProxies = all()
            let rid = UserDefaults.standard.integer(forKey: kSelectedProxyKey)
            if let proxy = allProxies.first(where: { $0.rid == rid }) {
                currentProxy = proxy
            } else {
                currentProxy = allProxies.first
            }
        }
    }
    
    // MARK: - QRCode
    func saveQRcode(with qrString: String?) -> Bool {
        guard let proxy = decodeQRCode(with: qrString) else {
            return false
        }
        return save(proxy: proxy)
    }
    
    func decodeQRCode(with qrString: String?) -> Proxy? {
        guard let qr = qrString, let url = URL(string: qr) else { return nil }
        guard let scheme = url.scheme, let base64Str = url.host else { return nil }
        if let user = url.user {
            guard let data = Data(base64Encoded: user), let userStr = String(data: data, encoding: String.Encoding.utf8), let last = qr.substring(from: "@") else { return nil }
            return convertedProxyWith(url: "\(scheme)://\(userStr)@\(last)")
        } else {
            // 修正 BASE64 编码串
            var fixBase64Str = base64Str
            let dotCount = fixBase64Str.count % 4
            if dotCount != 0 {
                fixBase64Str = (0..<(4-dotCount)).reduce(fixBase64Str, { (str, _) -> String in
                    return str + "="
                })
            }
            // Data
            guard let data = Data(base64Encoded: fixBase64Str), let dataStr = String(data: data, encoding: String.Encoding.utf8) else { return nil }
            return convertedProxyWith(url: "\(scheme)://\(dataStr)")
        }
    }
    
    // 解码后的 URL 转换成 Proxy
    func convertedProxyWith(url: String) -> Proxy? {
        guard let encodeUrl = URL(string: url),
            let scheme = encodeUrl.scheme, let host = encodeUrl.host, let port = encodeUrl.port, let type = ProxyType(with: scheme) else {
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
