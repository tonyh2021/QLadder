//
//  ConfigManager.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/23.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import Foundation

private struct ProxyDictKey {
    static let name = "name"
    static let host = "host"
    static let port = "port"
    static let passwd = "passwd"
}

private let KUserDefaultsProxys: String = {
    return "KUserDefaultsProxys"
}()

protocol ConfigManagerDelegate: class {
    func manager(_ manager: ConfigManager, didReceivedConfig proxy: Proxy?)
}

class ConfigManager {
    static let shared = ConfigManager()
    
    weak var delegate: ConfigManagerDelegate?
    
    var currentProxy: Proxy?
    
    var proxys: [Proxy] = [] {
        didSet {
            if proxys.count > 0 {
                let index = Int(arc4random_uniform(UInt32(proxys.count)))
//                print(index)
                currentProxy = proxys[index]
            } else {
                currentProxy = Proxy(name: "", host: "0.0.0.0", port: 0, password: "0")
            }
            delegate?.manager(self, didReceivedConfig: currentProxy)
        }
    }
    
    fileprivate init() {
        guard let _ = UserDefaults.standard.array(forKey: KUserDefaultsProxys) else {
            UserDefaults.standard.set([[String: String]](), forKey: KUserDefaultsProxys)
            return
        }
    }

    deinit {
    }
    
    public func loadConfig() {
//        print(String(describing: Proxy.self))
        if let dicts = UserDefaults.standard.array(forKey: KUserDefaultsProxys) {
            convertModel(dicts as! [[String: String]])
        }
    }
    
    func convertModel(_ dicts:[[String: String]]) {
//        print(type(of: dicts))
        var tmpProxys: [Proxy] = [];
        for dict in dicts {
            let name = dict[ProxyDictKey.name] ?? ""
            let host = dict[ProxyDictKey.host] ?? ""
            let port = dict[ProxyDictKey.port] ?? "0"
            let password = dict[ProxyDictKey.passwd] ?? ""
            let proxy = Proxy(name: name, host: host, port: Int(port)!, password: password)
            tmpProxys.append(proxy)
        }
        proxys = tmpProxys
    }
    
    func saveConfig(host: String, port: String, passwd: String) {
        var proxys = [[String: String]]()
//        var proxys = UserDefaults.standard.array(forKey: KUserDefaultsProxys) ?? []
        let proxy = [ProxyDictKey.host: host, ProxyDictKey.port: port, ProxyDictKey.passwd: passwd]
        proxys.append(proxy)
        UserDefaults.standard.set(proxys, forKey: KUserDefaultsProxys)
    }
}
