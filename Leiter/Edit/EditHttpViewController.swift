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
            proxyModeCell.detailTextLabel?.text = proxyMode.description
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private lazy var protocolCell: SwitchCell = {
        let cell = SwitchCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "Https"
        return cell
    }()
    private lazy var identifierCell: TextFieldCell = {
        let cell = TextFieldCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "名称"
        cell.textField.placeholder = "Optional"
        return cell
    }()
    private lazy var serverCell: TextFieldCell = {
        let cell = TextFieldCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "服务器"
        cell.textField.placeholder = "Required"
        return cell
    }()
    private lazy var portCell: TextFieldCell = {
        let cell = TextFieldCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "端口"
        cell.textField.placeholder = "1-65535"
        cell.textField.keyboardType = UIKeyboardType.decimalPad
        return cell
    }()
    
    private lazy var verfiyCell: SwitchCell = {
        let cell = SwitchCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "需要验证"
        return cell
    }()
    private lazy var usernameCell: TextFieldCell = {
        let cell = TextFieldCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "用户名"
        cell.textField.placeholder = "Optional"
        return cell
    }()
    private lazy var passwordCell: TextFieldCell = {
        let cell = TextFieldCell(style: .default, reuseIdentifier: nil)
        cell.titleLabel.text = "密码"
        cell.textField.placeholder = "Optional, Max Length 128"
        cell.textField.isSecureTextEntry = true
        return cell
    }()
    private lazy var proxyModeCell: UITableViewCell = {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "代理模式"
        cell.textLabel?.font = UIFont.pingfangRegular(15)
        cell.detailTextLabel?.text = "自动代理模式"
        cell.detailTextLabel?.font = UIFont.pingfangRegular(14)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    private var cells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加 Http(s)"
        saveButton.isEnabled = false
        cells = [protocolCell ,identifierCell, serverCell, portCell, verfiyCell, proxyModeCell]
        let serverSignal = serverCell.textField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
        let portSignal = portCell.textField.reactive.signal(forKeyPath: #keyPath(UITextField.text))
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
        r.identifier = identifierCell.textField.text.isEmpty ? nil : identifierCell.textField.text
        if let server = serverCell.textField.text {
            r.server = server
        }
        if let port = portCell.textField.text, let portNumber = Int(port) {
            r.port = portNumber
        }
        r.isHttps = protocolCell.switchControl.isOn
        r.isVerfiy = verfiyCell.switchControl.isOn
        if verfiyCell.switchControl.isOn {
            r.username = usernameCell.textField.text
            r.password = passwordCell.textField.text
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
            identifierCell.textField.text = proxy.identifier
            protocolCell.switchControl.isOn = proxy.isHttps
            serverCell.textField.text = proxy.server
            portCell.textField.text = "\(proxy.port)"
            verfiyCell.switchControl.isOn = proxy.isVerfiy
            proxyMode = proxy.mode
            usernameCell.textField.text = proxy.username
            passwordCell.textField.text = proxy.password
        }
        toggleVerfiySwitch()
        verfiyCell.switchControl.addTarget(self, action: #selector(toggleVerfiySwitch), for: .touchUpInside)
    }
    
    @objc private func toggleVerfiySwitch() {
        if verfiyCell.switchControl.isOn {
            cells = [protocolCell ,identifierCell, serverCell, portCell, verfiyCell, usernameCell, passwordCell, proxyModeCell]
        } else {
            cells = [protocolCell ,identifierCell, serverCell, portCell, verfiyCell, proxyModeCell]
        }
        tableView.reloadData()
    }
}

extension EditHttpViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.item]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if proxyModeCell == cells[indexPath.item] {
            let vc = ProxyModeViewController(proxyMode: proxyMode, completionAction: { [weak self] (proxyMode) in
                self?.proxyMode = proxyMode
            })
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
