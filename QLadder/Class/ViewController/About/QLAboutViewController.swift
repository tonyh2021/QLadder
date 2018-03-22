//
//  QLAboutViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/16.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit

class QLAboutViewController: QLBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonItemDidClick))
        navigationItem.title = "关于"
    }
    
    @objc private func rightBarButtonItemDidClick() {
        let vc = QDBuddhaListViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
