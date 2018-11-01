//
//  VpnManager.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/20.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import Foundation
import NetworkExtension

public enum ManagerError: Error {
    case invalidProvider
    case vpnStartFail
}

public enum VpnStatus {
    case off
    case connecting
    case on
    case disconnecting
}

protocol VpnManagerDelegate: class {
    func manager(_ manager: VpnManager, didChangeStatus status: VpnStatus)
}

class VpnManager {
    static let shared = VpnManager()
    
    weak var delegate: VpnManagerDelegate?

    var observerDidAdd: Bool = false
    
    fileprivate(set) var vpnStatus = VpnStatus.off {
        didSet {
            delegate?.manager(self, didChangeStatus: vpnStatus)
        }
    }
    
    fileprivate init() {
        loadProviderManager {
            if let manager = $0 {//$0就是闭包的第一个参数
                self.updateVPNStatus(manager)
            }
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 添加vpn的状态的监听
    func addVPNStatusObserver() {
        guard !observerDidAdd else {
            return
        }
        loadProviderManager {
            if let manager = $0 {
                self.observerDidAdd = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                })
            }
        }
    }
    
    /// 更新vpn的连接状态
    ///
    /// - Parameter manager: NEVPNManager
    func updateVPNStatus(_ manager: NEVPNManager) {
        
        switch manager.connection.status {
        case .connected:
            vpnStatus = .on
        case .connecting, .reasserting://reasserting  暂时无法获得确切状态
            vpnStatus = .connecting
        case .disconnecting:
            vpnStatus = .disconnecting
        case .disconnected, .invalid://invalid 无效状态，配置有错
            vpnStatus = .off
        }
    }
    
    /// 切换vpn
    open func switchVPN() {
        
    }
}

// load VPN Profiles
extension VpnManager {
    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.protocolConfiguration = NETunnelProviderProtocol()
        return manager
    }
    
    func loadAndCreateProviderManager(_ complete: @escaping (NETunnelProviderManager?, Error?) -> Void ) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers else { return }
            let manager: NETunnelProviderManager
            if (managers.count > 0) {
                manager = managers[0]
            } else {
                manager = self.createProviderManager()
            }
            manager.isEnabled = true
            manager.localizedDescription = AppConfig.appName
            manager.protocolConfiguration?.serverAddress = AppConfig.appName
            manager.isOnDemandEnabled = true
//            默认的配置
            self.setConnectionConfig(manager)
            manager.saveToPreferences {
                if let error = $0 {
                    complete(nil, error)
                } else {
                    manager.loadFromPreferences(completionHandler: { (error) -> Void in
                        if let error = error {
                            complete(nil, error)
                        } else {
                            complete(manager, nil)
                        }
                    })
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
}


// MARK: - public func
extension VpnManager {
    
    public func isVPNStarted(_ complete: @escaping (Bool, NETunnelProviderManager?) -> Void) {
        loadProviderManager {
            if let manager = $0 {
                complete(manager.connection.status == .connected, manager)
            } else {
                complete(false, nil)
            }
        }
    }
    
    public func startVPN(_ complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        startVPNWithOptions(nil, complete: complete)
    }
    
    fileprivate func startVPNWithOptions(_ options: [String : NSObject]?, complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        // Load provider
        loadAndCreateProviderManager { (manager, error) -> Void in
            if let error = error {
                complete?(nil, error)
            } else {
                guard let manager = manager else {
                    complete?(nil, ManagerError.invalidProvider)
                    return
                }
                if manager.connection.status == .disconnected || manager.connection.status == .invalid {
                    do {
                        try manager.connection.startVPNTunnel(options: options)
                        self.addVPNStatusObserver()
                        complete?(manager, nil)
                    }catch {
                        complete?(nil, error)
                    }
                } else {
                    self.addVPNStatusObserver()
                    complete?(manager, nil)
                }
            }
        }
    }
    
    public func stopVPN() {
        // Stop provider
        loadProviderManager {
            guard let manager = $0 else {
                return
            }
            manager.connection.stopVPNTunnel()
        }
    }
}

// Generate and Load ConfigFile
extension VpnManager {
    
    fileprivate func getRuleConf() -> String {
        let path = Bundle.main.path(forResource: "NEKitRule", ofType: "conf")
        let data = try? Foundation.Data(contentsOf: URL(fileURLWithPath: path!))
        let str = String(data: data!, encoding: String.Encoding.utf8)!
        return str
    }
    
    fileprivate func setConnectionConfig(_ manager:NETunnelProviderManager) {
        var conf = [String:AnyObject]()
//        conf["ss_address"] = "201.244.92.221" as AnyObject?//这里填写你的ss-server地址
//        conf["ss_port"] = 8899 as AnyObject?//ss-server端口
//        conf["ss_method"] = "AES256CFB" as AnyObject? // 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
//        conf["ss_password"] = "1234" as AnyObject?// ss-server 密码
        if let proxy = ConfigManager.shared.currentProxy {
            conf["ss_address"] = proxy.host as AnyObject?
            conf["ss_port"] = proxy.port as AnyObject?
            conf["ss_method"] = "AES256CFB" as AnyObject? // 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
            conf["ss_password"] = proxy.password as AnyObject?
            
            conf["ymal_conf"] = getRuleConf() as AnyObject?
            let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
            orignConf.providerConfiguration = conf
            manager.protocolConfiguration = orignConf
        }
    }

}
