//
//  Buddha.swift
//  QLadder
//
//  Created by qd-hxt on 2018/3/19.
//  Copyright © 2018年 qding. All rights reserved.
//

import Foundation

struct Buddha {
    
    var name: String?
    var url: String?
    var imgUrl: String?
    var time: String?
    var timeStamp: String?
    var user: String?
    
    init(name: String, url: String, imgUrl: String, time: String, timeStamp: String, user: String) {
        self.name = name
        self.url = url
        self.imgUrl = imgUrl
        self.time = time
        self.timeStamp = timeStamp
        self.user = user
    }
}
