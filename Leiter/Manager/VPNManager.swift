//
//  VPNManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/7/3.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift
import NetworkExtension
import NEKit

enum VPNStatus {
    case off
    case connecting
    case on
    case disconnecting
}

// MARK: - VPNManager
class VPNManager {
    
    
    var observerAdded: Bool = false
    fileprivate(set) var status = VPNStatus.off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.ProxyServiceStatusNotification, object: nil)
        }
    }
    
    static let shared = VPNManager()
    private init() {
        
        loadProviderManager { [weak self] in
            guard let manager = $0 else{ return }
            self?.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    func connect() {
        loadAndCreatePrividerManager { (manager) in
            guard let manager = manager else{return}
            do{
                try manager.connection.startVPNTunnel(options: [:])
            }catch let err{
                print(err)
            }
        }
    }
    
    func disconnect(){
        loadProviderManager { $0?.connection.stopVPNTunnel() }
    }
}

// MARK: - Load

extension VPNManager {
    
    private func loadAndCreatePrividerManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ) {
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            let currentManager: NETunnelProviderManager
            if let managers = managers, let manager = managers.first {
                currentManager = manager
                self.delDupConfig(managers)
            } else {
                currentManager = self.createProviderManager()
            }
            
            currentManager.isEnabled = true
            self.setRulerConfig(currentManager)
            currentManager.saveToPreferences{
                if $0 != nil{complete(nil);return;}
                currentManager.loadFromPreferences{
                    if $0 != nil{
                        print($0.debugDescription)
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(currentManager)
                }
            }
        }
    }
    
    private func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let config = NETunnelProviderProtocol()
        config.serverAddress = "127.0.0.1"
        manager.protocolConfiguration = config
        manager.localizedDescription = "Leiter Pro"
        return manager
    }
    
    private func delDupConfig(_ managers: [NETunnelProviderManager]) {
        if managers.count > 1 {
            managers.forEach { (manager) in
                DDLogInfo("Del DUP Profiles")
                manager.removeFromPreferences(completionHandler: { (error) in
                    if let err = error {
                        DDLogWarn(err.localizedDescription)
                    }
                })
            }
        }
    }
}

// Generate and Load ConfigFile
extension VPNManager {
    private func getRuleConf() -> String {
        
        guard let path = Bundle.main.path(forResource: "config.template.ss.general", ofType: "yaml") else {
            return ""
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let str = String(data: data, encoding: String.Encoding.utf8)
            return str ?? ""
        } catch {
            DDLogError("Load Config Error: \(error.localizedDescription)")
            return ""
        }
    }
    // ss://rc4-md5:msx123456@ss.tuluobo.com:8080?Remark=Linode-VPS&OTA=false
    private func setRulerConfig(_ manager: NETunnelProviderManager) {
        var config = [String: Any]()
        config["ss_address"] = "ss.tuluobo.com"
        config["ss_port"] = 8080
        config["ss_method"] = CryptoAlgorithm.RC4MD5.rawValue // 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
            config["ss_password"] = "msx123456"
        config["ymal_conf"] = getRuleConf()
        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConf.providerConfiguration = config
        manager.protocolConfiguration = orignConf
    }
}

// MARK: - Init

extension VPNManager {
    
    private func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let manager = managers?.first else {
                complete(nil)
                return
            }
            complete(manager)
        }
    }
    
    private func addVPNStatusObserver() {
        guard !observerAdded else{ return }
        
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                self.observerAdded = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                })
            }
        }
    }
    
    private func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.status = .on
        case .connecting, .reasserting:
            self.status = .connecting
        case .disconnecting:
            self.status = .disconnecting
        case .disconnected, .invalid:
            self.status = .off
        }
        DDLogInfo("\(self.status)")
    }
}

