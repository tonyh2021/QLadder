//
//  QLNewViewController.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/16.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import UIKit

protocol QLNewViewControllerDelegate: class {
    func newViewControllerDidAddConfig(_ controller: QLNewViewController)
}

class QLNewViewController: QLBaseViewController {
    
    weak var delegate: QLNewViewControllerDelegate?
    
    
    @IBOutlet weak var hostTextField: UITextField!
    
    private var host: String = ""
    
    @IBOutlet weak var portTextField: UITextField!
    
    private var port: String = ""
    
    @IBOutlet weak var passwdTextField: UITextField!
    
    private var passwd: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostTextField.keyboardType = .decimalPad
        hostTextField.returnKeyType = .next
        
        portTextField.keyboardType = .numberPad
        portTextField.returnKeyType = .next
        
        passwdTextField.delegate = self
        passwdTextField.keyboardType = .asciiCapable
        passwdTextField.returnKeyType = .done
        
        navigationItem.title = "新建"
    }
    
    @IBAction func addDidClick(_ sender: Any?) {
        host = hostTextField.text ?? ""
        port = portTextField.text ?? ""
        passwd = passwdTextField.text ?? ""
        
        if host != "" && port != "" && passwd != "" {
            ConfigManager.shared.saveConfig(host: host, port: port, passwd: passwd)
            delegate?.newViewControllerDidAddConfig(self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension QLNewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwdTextField {
            textField.resignFirstResponder()
            addDidClick(nil)
        }
        return true
    }
}
