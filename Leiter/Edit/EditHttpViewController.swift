//
//  EditHttpViewController.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ReactiveSwift
import SVProgressHUD

protocol EditProxyProtocol {
    var proxy: Proxy? { get set }
}

class EditHttpViewController: UITableViewController, EditProxyProtocol {

    var proxy: Proxy? {
        didSet {
            updateUIs()
        }
    }
    var proxyMode: ProxyMode = .general {
        didSet {
            proxyModeLable?.text = proxyMode.description
        }
    }
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var isHttpsSwitch: UISwitch!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var isVerfiySwitch: UISwitch!
    @IBOutlet weak var proxyModeLable: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    
    @IBOutlet weak var usernameCell: UITableViewCell!
    @IBOutlet weak var passwordCell: UITableViewCell!
    @IBOutlet weak var proxyModeCell: UITableViewCell!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Http(s)"
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
        r.type = .http
        r.identifier = identifierTextField.text.isEmpty ? nil : identifierTextField.text
        if let server = serverTextField.text {
            r.server = server
        }
        if let port = portTextField.text, let portNumber = Int(port) {
            r.port = portNumber
        }
        r.isHttps = isHttpsSwitch.isOn
        r.isVerfiy = isVerfiySwitch.isOn
        if isVerfiySwitch.isOn {
            r.username = usernameTextField.text
            r.password = passwdTextField.text
        } else {
            r.username = nil
            r.password = nil
        }
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
            isHttpsSwitch?.isOn = proxy.isHttps
            serverTextField?.text = proxy.server
            portTextField?.text = "\(proxy.port)"
            isVerfiySwitch?.isOn = proxy.isVerfiy
            proxyMode = proxy.mode
            passwdTextField.text = proxy.username
            passwdTextField.text = proxy.password
        }
        usernameCell.isHidden = !(proxy?.isVerfiy ?? false)
        passwordCell.isHidden = !(proxy?.isVerfiy ?? false)
        isVerfiySwitch.addTarget(self, action: #selector(toggleVerfiySwitch(sender:)), for: .touchUpInside)
    }
    
    @objc private func toggleVerfiySwitch(sender: UISwitch) {
        usernameCell.isHidden = !sender.isOn
        passwordCell.isHidden = !sender.isOn
    }
}

extension EditHttpViewController {
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
