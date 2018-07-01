//
//  BaseModel.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import WCDBSwift
import CocoaLumberjackSwift

protocol BaseModel: TableCodable {
    static var prefix: String { get }
    static var tableName: String { get }
    
    static func createTable(database: Database?)
}

extension BaseModel {
    static var prefix: String {
        return "lt_"
    }
    
    static var tableName: String {
        return prefix + "\(self)".lowercased()
    }
    
    static func createTable(database: Database?) {
        guard let database = database else { return }
        let table = tableName
        do {
            let exist = try database.isTableExists(table)
            if !exist {
                try database.create(table: table, of: self)
            }
        } catch {
            DDLogError("Create table \(tableName) error: \(error.localizedDescription)")
        }
    }
}
