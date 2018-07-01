//
//  EditSSViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import NEKit
import SPBaseKit
import ReactiveCocoa
import ReactiveSwift
import SVProgressHUD

class EditSSViewController: UITableViewController {
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private var routeMode: RouteMode = .split
    private var encryption: CryptoAlgorithm = .AES256CFB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Shadowsocks"
        saveButton.isEnabled = false
        
        let serverSignal = serverTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let portSignal = portTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let passwdSignal = passwdTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        saveButton.reactive.isEnabled <~ Signal.combineLatest(serverSignal, portSignal, passwdSignal).observe(on: UIScheduler()).map { (server, port, passwd) -> Bool in
            guard let server = server as? String, !server.isEmpty else { return false }
            guard let port = port as? String, let portNumber = Int(port), portNumber > 0 else { return false }
            guard let passwd = passwd as? String, !passwd.isEmpty else { return false }
            return true
        }
        
        // 测试 rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
        serverTextField.text = "ss.tuluobo.com"
        portTextField.text = "8080"
        passwdTextField.text = "msx123456"
        encryption = .RC4MD5
    }
    
    @IBAction func clickedSaveBtn(_ sender: UIBarButtonItem) {
        var r = Route()
        r.type = .shadowsocks
        r.identifier = identifierTextField.text.isEmpty ? nil : identifierTextField.text
        if let server = serverTextField.text {
            r.server = server
        }
        if let port = portTextField.text, let portNumber = Int(port) {
            r.port = portNumber
        }
        r.password = passwdTextField.text
        r.encryption = encryption
        r.mode = routeMode
        if RouteManager.shared.save(route: r) {
            SVProgressHUD.showSuccess(withStatus: "保存成功！")
            NotificationCenter.default.post(name: NSNotification.Name.RouteAddSuccess, object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "保存失败！")
        }
    }
}
