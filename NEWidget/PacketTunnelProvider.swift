//
//  PacketTunnelProvider.swift
//  NEWidget
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CocoaLumberjackSwift
import NEKit
import NetworkExtension
import Yaml

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    var interface: TUNInterface!
    // Since tun2socks is not stable, this is recommended to set to false
    var enablePacketProcessing = false
    
    var proxyServer: ProxyServer!
    var proxyPort: Int!
    
    var lastPath:NWPath?
    var started = false

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        DDLog.removeAllLoggers()
        // warning: setting to .Debug level might be way too verbose.
        DDLog.add(DDASLLogger.sharedInstance, with: DDLogLevel.info)
        // Use the build-in debug observer.
        ObserverFactory.currentFactory = DebugObserverFactory()
        DDLogError("startTunnel:-----------------")
        guard let config = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration,
            let configString = config["proxy_conf"] as? String else {
            NSLog("[ERROR] No ProtocolConfiguration Found Or Nil")
            exit(EXIT_FAILURE)
        }
        
        // Rules
        let configHelper: ConfigParserHelper
        do {
              configHelper = try ConfigParserHelper(with: configString)
        } catch {
            fatalError("[ERROR] Rule Configuration read Error:\(error.localizedDescription)")
        }
        RuleManager.currentManager = configHelper.ruleManager
        proxyPort = configHelper.proxyPort ?? 9933
        RawSocketFactory.TunnelProvider = self
        
        // the `tunnelRemoteAddress` is meaningless because we are not creating a tunnel.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.10.10.10")
        networkSettings.mtu = 1500
        
        let ipv4Settings = NEIPv4Settings(addresses: ["192.169.189.1"], subnetMasks: ["255.255.255.0"])
        if enablePacketProcessing {
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
            ipv4Settings.excludedRoutes = [
                NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
                NEIPv4Route(destinationAddress: "100.64.0.0", subnetMask: "255.192.0.0"),
                NEIPv4Route(destinationAddress: "127.0.0.0", subnetMask: "255.0.0.0"),
                NEIPv4Route(destinationAddress: "169.254.0.0", subnetMask: "255.255.0.0"),
                NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
                NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
                NEIPv4Route(destinationAddress: "17.0.0.0", subnetMask: "255.0.0.0"),
            ]
        }
        networkSettings.ipv4Settings = ipv4Settings
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.excludeSimpleHostnames = true
        // This will match all domains
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = ["api.smoot.apple.com","configuration.apple.com","xp.apple.com","smp-device-content.apple.com","guzzoni.apple.com","captive.apple.com","*.ess.apple.com","*.push.apple.com","*.push-apple.com.akadns.net"]
        networkSettings.proxySettings = proxySettings
        
        if enablePacketProcessing {
            let DNSSettings = NEDNSSettings(servers: ["198.18.0.1"])
            DNSSettings.matchDomains = [""]
            DNSSettings.matchDomainsNoSearch = false
            networkSettings.dnsSettings = DNSSettings
        }
        
        setTunnelNetworkSettings(networkSettings) {
            error in
            guard error == nil else {
                DDLogError("Encountered an error setting up the network: \(error.debugDescription)")
                completionHandler(error)
                return
            }
            
            if !self.started {
                self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: "127.0.0.1"), port: NEKit.Port(port: UInt16(self.proxyPort)))
                try! self.proxyServer.start()
                self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
            } else {
                self.proxyServer.stop()
                try! self.proxyServer.start()
            }
            
            completionHandler(nil)
            
            if (self.enablePacketProcessing) {
                if self.started {
                    self.interface.stop()
                }
                
                self.interface = TUNInterface(packetFlow: self.packetFlow)
                
                let fakeIPPool = try! IPPool(range: IPRange(startIP: IPAddress(fromString: "198.18.1.1")!, endIP: IPAddress(fromString: "198.18.255.255")!))
                
                
                let dnsServer = DNSServer(address: IPAddress(fromString: "198.18.0.1")!, port: NEKit.Port(port: 53), fakeIPPool: fakeIPPool)
                let resolver = UDPDNSResolver(address: IPAddress(fromString: "114.114.114.114")!, port: NEKit.Port(port: 53))
                dnsServer.registerResolver(resolver)
                self.interface.register(stack: dnsServer)
                
                DNSServer.currentServer = dnsServer
                
                let udpStack = UDPDirectStack()
                self.interface.register(stack: udpStack)
                let tcpStack = TCPStack.stack
                tcpStack.proxyServer = self.proxyServer
                self.interface.register(stack:tcpStack)
                self.interface.start()
            }
            self.started = true
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        if enablePacketProcessing {
            interface.stop()
            interface = nil
            DNSServer.currentServer = nil
        }
        
        proxyServer.stop()
        proxyServer = nil
        RawSocketFactory.TunnelProvider = nil
        
        completionHandler()
        
        //框架作者并不知道为何还会运行一会儿，这样会导致无法立即开始另一个配置，所以此处进行手动的崩溃。
        exit(EXIT_SUCCESS)
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
}

extension PacketTunnelProvider {
    /// 监听网络状态，切换不同的网络的时候，需要重新连接vpn
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "defaultPath" {
            if self.defaultPath?.status == .satisfied && self.defaultPath != self.lastPath {
                if (self.lastPath == nil) {
                    self.lastPath = self.defaultPath
                } else {
                    NSLog("received network change notifcation")
                    let xSeconds = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + xSeconds) {
                        self.startTunnel(options: nil){ _ in }
                    }
                }
            } else {
                self.lastPath = defaultPath
            }
        }
        
    }
}
