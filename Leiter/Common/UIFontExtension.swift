//
//  UIFontExtension.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/8.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

extension UIFont {
    static func pingfangRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
