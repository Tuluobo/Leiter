//
//  EditSocks5ViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import SPBaseKit
import ReactiveSwift
import SVProgressHUD

class EditSocks5ViewController: UITableViewController, EditProxyProtocol {

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
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var proxyModeLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var proxyModeCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Sockks5"
        saveButton.isEnabled = false
        
        let serverSignal = serverTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let portSignal = portTextField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        saveButton.reactive.isEnabled <~ Signal.combineLatest(serverSignal, portSignal).observe(on: UIScheduler()).map { (server, port) -> Bool in
            guard !(server as? String).isEmpty else { return false }
            guard let port = port as? String, let portNumber = Int(port), portNumber > 0 else { return false }
            return true
        }
        updateUIs()
    }
    
    @IBAction func clickedSaveBtn(_ sender: UIBarButtonItem) {
        var r = self.proxy ?? Proxy()
        r.type = .socks5
        r.identifier = identifierTextField.text.isEmpty ? nil : identifierTextField.text
        if let server = serverTextField.text {
            r.server = server
        }
        if let port = portTextField.text, let portNumber = Int(port) {
            r.port = portNumber
        }
        r.mode = proxyMode
        if ProxyManager.shared.save(proxy: r) {
            SVProgressHUD.showSuccess(withStatus: "保存成功！")
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
            proxyMode = proxy.mode
        } else {
            #if DEBUG
            identifierTextField?.text = "socks5_\(arc4random_uniform(100))"
            serverTextField?.text = "192.168.1.233"
            portTextField?.text = "1086"
            #endif
        }
    }
}

extension EditSocks5ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if proxyModeCell == cell {
            let vc = ProxyModeViewController(proxyMode: proxyMode, completionAction: { [weak self] (proxyMode) in
                self?.proxyMode = proxyMode
            })
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
