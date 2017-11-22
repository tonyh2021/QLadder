//
//  QLHomeViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/16.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit


class QLHomeViewController: QLBaseViewController, VpnManagerDelegate {

    @IBOutlet weak var connectButton: UIButton!
    
    var status: VpnStatus {
        didSet(o) {
            updateConnectButtonText(status: o)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        status = .off
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VpnManager.shared.delegate = self as VpnManagerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        status = VpnManager.shared.vpnStatus
    }
    
    func updateConnectButtonText(status: VpnStatus) {
        switch status {
        case .connecting:
            connectButton.setTitle("连接中...", for: .normal)
        case .disconnecting:
            connectButton.setTitle("断开中...", for: .normal)
        case .on:
            connectButton.setTitle("断开", for: .normal)
        case .off:
            connectButton.setTitle("连接", for: .normal)
        }
        connectButton.isEnabled = [VpnStatus.on, VpnStatus.off].contains(status)
    }
    
    @IBAction func connect(_ sender: UIButton) {
        if (VpnManager.shared.vpnStatus == .off) {
            VpnManager.shared.startVPN()
        } else {
            VpnManager.shared.stopVPN()
        }
    }
    
}

extension QLHomeViewController {
    func vpnManager(_ vpnManager: VpnManager, didChangeStatus status: VpnStatus) {
        self.updateConnectButtonText(status: status)
    }
}
