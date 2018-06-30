//
//  ConfigManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import Fabric
import Crashlytics

class ConfigManager {
    
    static let `default` = ConfigManager()
    private init() { }

    func setup() {
        Fabric.with([Crashlytics.self])
        TrackerManager.shared.setup()
    }
}

