//
//  QLAboutViewController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/16.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import UIKit

class QLAboutViewController: QLBaseViewController {

    @IBOutlet weak var passwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonItemDidClick))
        navigationItem.title = "关于"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        passwdTextField.text = nil
        view.endEditing(true)
    }
    
    @objc func tap(tapGesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func rightBarButtonItemDidClick() {
        
        guard let passwd = passwdTextField.text, passwd == "porn" else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let button1 = UIAlertAction(title: "91 Porn", style: .default) { (action: UIAlertAction!) -> Void in
            let vc = QLBuddhaListViewController(buddhaType: .porn_91)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(button1)
        
        let button2 = UIAlertAction(title: "PornHub", style: .default) { (action: UIAlertAction!) -> Void in
            let vc = QLBuddhaListViewController(buddhaType: .porn_hub)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(button2)
        
        let button3 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(button3)
        
        present(alertController, animated: true, completion: nil)
    }

}
