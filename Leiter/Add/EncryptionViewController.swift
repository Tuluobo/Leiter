//
//  EncryptionViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/1.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Eureka
import NEKit

class EncryptionViewController: FormViewController {

    var encryption: CryptoAlgorithm = .AES256CFB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加密方式"
        let section = Section()
        form +++ section
        for en in CryptoAlgorithm.allValues {
            section <<< CheckRow() { row in
                self.title = en.rawValue
            }
        }
    }
}
