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

class EditSSViewController: UITableViewController, EditProxyProtocol {
    
    var proxy: Proxy? {
        didSet {
            updateUIs()
        }
    }
    var proxyMode: ProxyMode = .general {
        didSet {
            proxyModeLabel?.text = proxyMode.description
        }
    }
    var encryption: CryptoAlgorithm = .AES256CFB {
        didSet {
            encryptionLabel?.text = encryption.rawValue
        }
    }
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var encryptionLabel: UILabel!
    @IBOutlet weak var proxyModeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Shadowsocks"
        saveButton.isEnabled = false
        
        let serverSignal = serverTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let portSignal = portTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let passwdSignal = passwdTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        saveButton.reactive.isEnabled <~ Signal.combineLatest(serverSignal, portSignal, passwdSignal).observe(on: UIScheduler()).map { (server, port, passwd) -> Bool in
            guard !(server as? String).isEmpty else { return false }
            guard let port = port as? String, let portNumber = Int(port), portNumber > 0 else { return false }
            guard !(passwd as? String).isEmpty else { return false }
            return true
        }
        updateUIs()
    }
    
    @IBAction func clickedSaveBtn(_ sender: UIBarButtonItem) {
        var r = self.proxy ?? Proxy()
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
        r.mode = proxyMode
        if ProxyManager.shared.save(proxy: r) {
            SVProgressHUD.showSuccess(withStatus: "保存成功！")
            NotificationCenter.default.post(name: Notification.Name.AddProxySuccessNotification, object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "保存失败！")
        }
    }
    
    private func updateUIs() {
        if let proxy = self.proxy {
            identifierTextField?.text = proxy.identifier
            serverTextField?.text = proxy.server
            portTextField?.text = "\(proxy.port)"
            passwdTextField?.text = proxy.password
            proxyMode = proxy.mode
            encryption = proxy.encryption ?? .AES256CFB
        } else {
            #if DEBUG
            identifierTextField?.text = "ss_\(arc4random_uniform(100))"
            serverTextField?.text = "ss.tuluobo.com"
            portTextField?.text = "8080"
            passwdTextField?.text = "msx123456"
            encryption = .RC4MD5
            #endif
        }
    }
}
