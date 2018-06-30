//
//  Route.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import Foundation
import NEKit

enum RouteType: Int {
    case http = 0
    case https
    case socket5
    case shadowsocks
}

enum RouteMode: Int {
    case split = 0
    case full
}

struct Route {
    var identifier: String?
    var server: String?
    var port: Int?
    var mode: RouteMode = .split
    var encryption: CryptoAlgorithm? = .AES128CFB
    var password: String?
    
}
