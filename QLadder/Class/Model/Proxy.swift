//
//  Proxy.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/23.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import Foundation

struct Proxy {
    
    var name: String?
    var host: String?
    var port: Int?
    var password: String?
    
    init(name: String, host: String, port: Int, password: String) {
        self.name = name
        self.host = host
        self.port = port
        self.password = password
    }
}
