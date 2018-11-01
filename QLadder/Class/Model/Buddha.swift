//
//  Buddha.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/19.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import Foundation

struct Buddha {
    
    var name: String?
    var url: String?
    var imgUrl: String?
    var duration: String?
    var addTime: String?
    var user: String?
    
    var videoUrl: String?
    var name_zh: String?
    var detailImgUrl: String?
    var addTime_zh: String?
    var points: String?
    
    init(name: String, url: String, imgUrl: String, duration: String, addTime: String, user: String) {
        self.name = name
        self.url = url
        self.imgUrl = imgUrl
        self.duration = duration
        self.addTime = addTime
        self.user = user
    }
    
    func mutableCopy(with zone: NSZone? = nil) -> Buddha {
        var mutableBuddha = Buddha(name: name ?? "", url: url ?? "", imgUrl: imgUrl ?? "", duration: duration ?? "", addTime: addTime ?? "", user: user ?? "")
        mutableBuddha.videoUrl = videoUrl  ?? ""
        mutableBuddha.name_zh = name_zh  ?? ""
        mutableBuddha.detailImgUrl = detailImgUrl  ?? ""
        mutableBuddha.addTime_zh = addTime_zh  ?? ""
        mutableBuddha.points = points  ?? ""
        return mutableBuddha
    }
}
