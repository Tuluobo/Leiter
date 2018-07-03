//
//  RoutModeViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

class RoutModeViewController: UITableViewController {

    var proxyMode: ProxyMode = .general
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "代理模式"
    }
}
