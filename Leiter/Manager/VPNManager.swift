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
            }catch let err {
                DDLogError("VPN Connect Error: \(err.localizedDescription)")
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
        config.serverAddress = "Leiter"
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
    private func getRuleConfig(_ proxy: Proxy) -> String {
        guard let path = Bundle.main.path(forResource: "config.template.\(proxy.type.scheme).\(proxy.mode.rawValue)", ofType: "yaml") else {
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
    
    private func replaceProxy(_ proxy: Proxy, ruleConfig: String) -> String {
        var config = ruleConfig
        switch proxy.type {
        case .http:
            // username: [attribute]http_username[/attribute]
            // password: [attribute]http_password[/attribute]
            config = config.replacingOccurrences(of: "[attribute]http_host[/attribute]", with: proxy.server)
            config = config.replacingOccurrences(of: "[attribute]http_port[/attribute]", with: "\(proxy.port)")
            config = config.replacingOccurrences(of: "[attribute]http_secured[/attribute]", with: "\(proxy.isHttps)")
            config = config.replacingOccurrences(of: "[attribute]http_auth[/attribute]", with: "\(proxy.isVerfiy)")
            config = config.replacingOccurrences(of: "[attribute]http_username[/attribute]", with: "")
            config = config.replacingOccurrences(of: "[attribute]http_password[/attribute]", with: "")
        case .socks5:
            config = config.replacingOccurrences(of: "[attribute]socks5_host[/attribute]", with: proxy.server)
            config = config.replacingOccurrences(of: "[attribute]socks5_port[/attribute]", with: "\(proxy.port)")
        case .shadowsocks:
            config = config.replacingOccurrences(of: "[attribute]ss_method[/attribute]", with: proxy.encryption?.rawValue ?? CryptoAlgorithm.AES256CFB.rawValue)
            config = config.replacingOccurrences(of: "[attribute]ss_host[/attribute]", with: proxy.server)
            config = config.replacingOccurrences(of: "[attribute]ss_port[/attribute]", with: "\(proxy.port)")
            config = config.replacingOccurrences(of: "[attribute]ss_password[/attribute]", with: proxy.password ?? "")
            config = config.replacingOccurrences(of: "[attribute]ss_protocol[/attribute]", with: "origin")
            config = config.replacingOccurrences(of: "[attribute]ss_obfs[/attribute]", with: "origin")
            config = config.replacingOccurrences(of: "[attribute]ss_obfsParam[/attribute]", with: "")
        }
        return config
    }
    
    private func setRulerConfig(_ manager: NETunnelProviderManager) {
        guard let proxy = ProxyManager.shared.currentProxy else {
            return
        }
        var ruleConfig = getRuleConfig(proxy)
        guard ruleConfig.count > 0 else {
            return
        }
        ruleConfig = replaceProxy(proxy, ruleConfig: ruleConfig)
        let orignConfiguration = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConfiguration.providerConfiguration = ["proxy_conf": ruleConfig]
        manager.protocolConfiguration = orignConfiguration
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
                NotificationCenter.default.addObserver(forName: Notification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
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
        DDLogInfo("updateVPNStatus: \(self.status)")
    }
}

