//
//  RoutModeViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Eureka

class RoutModeViewController: FormViewController {

    var routeMode: RouteMode = .split
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "代理模式"
        
        form +++ Section()
            <<< CheckRow() { row in
                row.title = "自动代理模式"
            }
            <<< CheckRow() { row in
                row.title = "全局代理模式"
            }
    }
}
