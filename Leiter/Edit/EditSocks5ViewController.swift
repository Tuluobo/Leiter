//
//  EditSocks5ViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

class EditSocks5ViewController: UITableViewController, EditProxyProtocol {

    var proxy: Proxy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Sockks5"
    }
}
