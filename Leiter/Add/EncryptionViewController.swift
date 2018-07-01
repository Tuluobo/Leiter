//
//  EncryptionViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import NEKit

class EncryptionViewController: UITableViewController {

    var encryption: CryptoAlgorithm = .AES256CFB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加密方式"
    }
}
