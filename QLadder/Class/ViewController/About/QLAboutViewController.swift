//
//  QLAboutViewController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/16.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import UIKit

class QLAboutViewController: QLBaseViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonItemDidClick))
        navigationItem.title = "关于"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.text = nil
        view.endEditing(true)
    }
    
    @objc func tap(tapGesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func rightBarButtonItemDidClick() {
        
        guard let typeText = textField.text else {
            return
        }
        
        var buddhaType:BuddhaType = .porn_none
        
        if typeText == "91" {
            buddhaType = .porn_91
        } else if typeText == "hub" {
            buddhaType = .porn_hub
        }
        
        if buddhaType != .porn_none {
            let vc = QLBuddhaListViewController(buddhaType: buddhaType)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
