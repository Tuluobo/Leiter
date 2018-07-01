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
        
        #if DEBUG
        Thread.sleep(forTimeInterval: 2.0)
        #endif
        
        TrackerManager.shared.trace(event: "app_start", properties: launchOptions)
        return true
    }
    //ss://rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
}

extension AppDelegate {
    private func commonUI() {
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = Opt.baseBlueColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

