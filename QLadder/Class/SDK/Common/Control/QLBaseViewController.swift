//
//  QLBaseViewController.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/16.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit

class QLBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = QLColor.C2

		let backImage = UIImage(named: "nav-back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		
		navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
		
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
		
        navigationController?.navigationBar.barTintColor = QLColor.C2
    }
}
