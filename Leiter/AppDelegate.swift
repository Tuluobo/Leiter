//
//  AppDelegate.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 基础配置
        ConfigManager.default.setup()
        commonUI()
        
        TrackerManager.shared.track(event: "app_start", properties: launchOptions)
        return true
    }

}

extension AppDelegate {
    private func commonUI() {
        UINavigationBar.appearance().barTintColor = UIColor(red: 51.0/255.0, green: 153.0/255.0, blue: 1.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

