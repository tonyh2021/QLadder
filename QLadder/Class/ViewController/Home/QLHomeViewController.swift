//
//  QLHomeViewController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/16.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import UIKit

class QLHomeViewController: QLBaseViewController, VpnManagerDelegate, ConfigManagerDelegate, QLNewViewControllerDelegate {

    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var proxyConfigLabel: UILabel!
    
    var isStatusBarHidden:Bool = true
    
    var status: VpnStatus {
        didSet {
            updateConnectButtonText(status: status)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        status = .off
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStatusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newConfig))
        navigationItem.title = "连接"
        
        ConfigManager.shared.delegate = self as ConfigManagerDelegate
        VpnManager.shared.delegate = self as VpnManagerDelegate
        
        ConfigManager.shared.loadConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        status = VpnManager.shared.vpnStatus
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateConnectButtonText(status: VpnStatus) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch status {
            case .connecting:
                self.connectButton.setTitle("连接中...", for: .normal)
            case .disconnecting:
                self.connectButton.setTitle("断开中...", for: .normal)
            case .on:
                self.connectButton.setTitle("断开", for: .normal)
            case .off:
                self.connectButton.setTitle("连接", for: .normal)
            }
            self.connectButton.isEnabled = [VpnStatus.on, VpnStatus.off].contains(status)
        }
    }
    
    @objc private func newConfig() {
        let newVC = QLNewViewController()
        newVC.hidesBottomBarWhenPushed = true
        newVC.delegate = self
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    @IBAction func connect(_ sender: UIButton) {
        if (VpnManager.shared.vpnStatus == .off) {
            VpnManager.shared.startVPN()
        } else {
            VpnManager.shared.stopVPN()
        }
    }
    
    func updateConfigUI(_ proxy: Proxy?) {
        if let proxy = proxy {
            connectButton.isEnabled = true
            if let host: String = proxy.host, let port: Int = proxy.port {
                proxyConfigLabel.text = "\(host):\(port)"
            }
        } else {
            connectButton.isEnabled = false
            proxyConfigLabel.text = "正在获取配置"
        }
    }
}

// MARK: - VpnManagerDelegate
extension QLHomeViewController {
    func manager(_ manager: VpnManager, didChangeStatus status: VpnStatus) {
        updateConnectButtonText(status: status)
    }
}

// MARK: - ConfigManagerDelegate
extension QLHomeViewController {
    func manager(_ manager: ConfigManager, didReceivedConfig proxy: Proxy?) {
        updateConfigUI(proxy)
    }
}

// MARK: - StatusBar
extension QLHomeViewController {
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
}

// MARK: - QLNewViewControllerDelegate
extension QLHomeViewController {
    func newViewControllerDidAddConfig(_ controller: QLNewViewController) {
        ConfigManager.shared.loadConfig()
        if (VpnManager.shared.vpnStatus == .on) {
            VpnManager.shared.stopVPN()
        }
    }
}

