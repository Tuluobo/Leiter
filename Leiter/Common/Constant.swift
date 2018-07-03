//
//  Constant.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

// MARK: - 基本常量

enum Opt {
    static let mainVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "0.0.1"
    static let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "1"
}

// MARK: - 颜色

extension Opt {
    static let baseBlueColor = UIColor(red: 53.0/255.0, green: 151.0/255.0, blue: 1.0, alpha: 1.0)
}

// MARK: - 通知

extension Notification.Name {
    static let AddProxySuccessNotification = Notification.Name("AddProxySuccessNotification")
}

