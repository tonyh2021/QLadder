//
//  QDBuddhaViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2018/3/22.
//  Copyright © 2018年 qding. All rights reserved.
//

import UIKit

class QDBuddhaViewController: QLBaseViewController {
    
    private var buddha: Buddha
    
    init(_ buddha: Buddha) {
        self.buddha = buddha
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // or see Roman Sausarnes's answer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
    }
    
    private func initSubviews() {
        
        navigationItem.title = buddha.name
        
    }
    
}

extension QDBuddhaViewController {

}
