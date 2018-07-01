//
//  RouteManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift
import WCDBSwift

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
    func saveQrCodeData(with qrString: String) -> Bool {
        // TODO: 解析
        return false
    }
    
    // ss://rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
    func createQRCodeData(with route: Route) -> String {
        return ""
    }
}
