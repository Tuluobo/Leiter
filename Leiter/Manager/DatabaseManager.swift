//
//  DatabaseManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import WCDBSwift
import CocoaLumberjackSwift

public class DatabaseManager {
    
    public static let shared = DatabaseManager()
    
    public var database: Database?
    
    private let databaseName = "leiter.db"
    private lazy var path: String? = {
        guard let documentPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last,
            let bundleIdentifier = Bundle.main.bundleIdentifier else {
                return nil
        }
        let p = documentPath + "/" + bundleIdentifier + "/" + databaseName
        return p
    }()
    
    private init() {
        if let path = path {
            self.database = Database(withPath: path)
            DDLogInfo("Database create: \(self.database.debugDescription)")
        }
    }
    
    public func setup() {
        createAllTables()
    }
    
    private func createAllTables() {
        do {
            try self.database?.run(transaction: {
                Proxy.createTable(database: self.database)
            })
        } catch {
            DDLogWarn("Database create table transaction error:\(error.localizedDescription)")
        }
    }
}
