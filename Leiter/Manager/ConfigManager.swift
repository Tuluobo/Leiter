//
//  ConfigManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift

class ConfigManager {
    
    static let `default` = ConfigManager()
    private init() { }

    func setup() {
        TrackerManager.shared.setup()
        
        /// Working
        if let logger = DDTTYLogger.sharedInstance {
            DDLog.add(logger) // TTY = Xcode console
        }
        DatabaseManager.shared.setup()
    }
}

