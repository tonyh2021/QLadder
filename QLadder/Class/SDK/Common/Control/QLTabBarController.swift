//
//  QLTabBarController.swift
//  QLadder
//
//  Created by qd-hxt on 2017/11/16.
//  Copyright © 2017年 qding. All rights reserved.
//

import UIKit

class QLTabBarController: UITabBarController {

    let images = [["tabbar-item-link", "tabbar-item-link-selected"],
                  ["tabbar-item-user", "tabbar-item-user-selected"],
                  ["tabbar-item-setting", "tabbar-item-setting-selected"]
                  ]
    let titles = ["连接", "我的", "设置"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : QLColor.C3], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : QLColor.C1], for: .selected)
        
        //自定义tabbar的item
        for (index, item) in (self.tabBar.items?.enumerated())! {
            item.image = UIImage(named: images[index][0])?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            item.selectedImage = UIImage(named: images[index][1])?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            item.title = titles[index];
        }
    }
}
