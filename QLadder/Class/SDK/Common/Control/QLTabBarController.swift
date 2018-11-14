//
//  QLTabBarController.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/16.
//  Copyright © 2017年 TonyHan All rights reserved.
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
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : QLColor.C3], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : QLColor.C3], for: .selected)
        
        //自定义tabbar的item
        for (index, item) in (self.tabBar.items?.enumerated())! {
            item.image = UIImage(named: images[index][0])?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            item.selectedImage = UIImage(named: images[index][1])?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            item.title = titles[index];
        }
    }
}
