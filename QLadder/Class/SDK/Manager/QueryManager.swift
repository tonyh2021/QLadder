//
//  QueryManager.swift
//  QLadder
//
//  Created by qd-hxt on 2018/3/19.
//  Copyright © 2018年 qding. All rights reserved.
//

import Foundation
import Alamofire
import Fuzi

class QueryManager {
    
    static let shared = QueryManager()
    
    typealias QueryResult = ([Buddha], String?) -> ()

    // 1
    let defaultSession = URLSession(configuration: .default)
    // 2
    var dataTask: URLSessionDataTask?
    var buddhas: [Buddha] = []
    
    private let pageSize = 20
    
    private let headers: HTTPHeaders = [
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7",
        "X-Forwarded-For": "119.123.123.21"
    ]
    
    func fetchBuddhas(page: Int, completion: @escaping QueryResult) {
        var url = ""
        if page <= 0 {
            url = "http://91porn.com/v.php?category=rf&viewtype=basic&page=1"
        } else {
            url = "http://91porn.com/v.php?category=rf&viewtype=basic&page=\(page)"
        }
        
        Alamofire.request(url)
            .responseString { response in
                
                if let error = response.error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(self.buddhas, error.localizedDescription)
                    }
                } else {
                    self.updateBuddhas(response.result.value! as NSString)
                    DispatchQueue.main.async {
                        completion(self.buddhas, nil)
                    }
                }
        }
    }
    
    fileprivate func updateBuddhas(_ htmlString: NSString) {

        if htmlString == "" {
            return
        }

        do {
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTMLDocument(string: htmlString as String, encoding: String.Encoding.utf8)
            
            // XPath queries
            
            var tempBuddhas = [Buddha]()
            
            for item in doc.xpath("//*[@class='listchannel']") {
                var name: String = ""
                var url: String = ""
                var imgUrl: String = ""
                var time: String = ""
                var timeStamp:String = ""
                var user: String = ""
                if let img = item.xpath("div/a[@target='blank']/img").first {
                    name = img["title"] ?? ""
                    imgUrl = img["src"] ?? ""
                }
                if let urlItem = item.xpath("a[@target='blank']").first {
                    url = urlItem["href"] ?? ""
                }
                for timeItem in item.xpath("text()") {
                    let text = timeItem.rawXML.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.contains(":") {
                        time = text
                    }
                    if text.contains("ago") {
                        timeStamp = text
                    }
                }
                if let userItem = item.xpath("a[@target='_parent']/text()").first {
                    user = userItem.rawXML
                }
                let buddha = Buddha(name: name, url: url, imgUrl: imgUrl, time: time, timeStamp: timeStamp, user: user)
                tempBuddhas.append(buddha)
            }
            buddhas = tempBuddhas
            
        } catch let error {
            print(error)
        }
        
    }
    
    private func setWatchTimesCookie() {
        //创建一个HTTPCookie对象
        var props = Dictionary<HTTPCookiePropertyKey, Any>()
        props[HTTPCookiePropertyKey.name] = "watch_times"
        props[HTTPCookiePropertyKey.value] = "1"
        props[HTTPCookiePropertyKey.path] = "/"
        props[HTTPCookiePropertyKey.domain] = "91porn.com"
        let cookie = HTTPCookie(properties: props)
        let cstorage = HTTPCookieStorage.shared
        //        通过setCookie方法把Cookie保存起来
        cstorage.setCookie(cookie!)
    }
}
