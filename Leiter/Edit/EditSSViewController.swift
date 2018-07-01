//
//  EditSSViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Eureka
import NEKit

class EditSSViewController: UITableViewController {
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    private var routeMode: RouteMode = .split
    private var encryption: CryptoAlgorithm = .AES256CFB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Shadowsocks"
    }
    
    @IBAction func clickedSaveBtn(_ sender: UIBarButtonItem) {
        
    }
}
