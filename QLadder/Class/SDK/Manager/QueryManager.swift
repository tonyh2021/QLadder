//
//  QueryManager.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/19.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import JavaScriptCore

class QueryManager {
    
    static let shared = QueryManager()
    
    typealias QueryResult = ([Buddha], String?) -> ()
    
    typealias QueryDetailResult = (Buddha, String?) -> ()
    
    
    /// 是否需要隐藏，隐藏后图片和标题变为英文
    var covertMode = true
    
    var covertImageUrl: String {
        let urls = [
            "https://pic1.zhimg.com/80/v2-55e8e364ceee397d6dac7db5964b1187_hd.jpg",
            "https://pic2.zhimg.com/80/v2-6e50b80726539aa10f93c8839fcef04c_hd.jpg",
            "https://pic1.zhimg.com/80/v2-aa2870bc4825833bed8661a6a29b3dc4_hd.jpg",
            "https://pic7.zhimg.com/80/v2-99e63cdc0ccc69cffaaab3453648ad2b_hd.jpg",
            "https://pic1.zhimg.com/80/v2-f579363fac082861e2744acb8140c0c7_hd.jpg",
            "https://pic2.zhimg.com/80/v2-fc0b5635984cff3aefa1988efadb18dc_hd.jpg",
            "https://pic1.zhimg.com/80/v2-9af7dbabd02c224026072efacfd11b4f_hd.jpg",
            "https://pic2.zhimg.com/80/v2-1b0b1d2eca953b008ea5e125cbe1d48e_hd.jpg"
            ]
        let index = Int(arc4random_uniform(UInt32(urls.count)))
        return urls[index]
    }
    
    // 1
    let defaultSession = URLSession(configuration: .default)
    // 2
    var dataTask: URLSessionDataTask?
    var buddhas: [Buddha] = []
    
    private var headers: HTTPHeaders {
        get {
            let ip = "\(arc4random_uniform(255) + 1).\(arc4random_uniform(255) + 1).\(arc4random_uniform(255) + 1).\(arc4random_uniform(255) + 1)"
            let headers = [
                "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7",
                "X-Forwarded-For": ip
            ]
            return headers
        }
    }
    
    // MARK: BuddhaList
    func fetchBuddhas(_ buddhaType: BuddhaType, _ page: Int, completion: @escaping QueryResult) {
        var url = ""
        if buddhaType == .porn_91 {
            if page <= 0 {
                url = "http://91porn.com/v.php?category=rf&viewtype=basic&page=1"
            } else {
                url = "http://91porn.com/v.php?category=rf&viewtype=basic&page=\(page)"
            }
            
            Alamofire.request(url)
                .responseData { response in
                    if let error = response.error {
                        print(error)
                        DispatchQueue.main.async {
                            completion(self.buddhas, error.localizedDescription)
                        }
                    } else {
                        if let data = response.data {
                            let htmlString = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
                            self.updateBuddhasIn91(htmlString as NSString)
                        }
                        DispatchQueue.main.async {
                            completion(self.buddhas, nil)
                        }
                    }
            }
        } else {
            if page <= 0 {
                url = "https://www.pornhub.com/video?o=mv&cc=us"
            } else {
                url = "https://www.pornhub.com/video?o=mv&cc=us&page=\(page)"
            }
            
            Alamofire.request(url)
                .responseString { response in
                    if let error = response.error {
                        print(error)
                        DispatchQueue.main.async {
                            completion(self.buddhas, error.localizedDescription)
                        }
                    } else {
                        self.updateBuddhasInHub(response.result.value! as NSString)
                        DispatchQueue.main.async {
                            completion(self.buddhas, nil)
                        }
                    }
            }
        }
    }
    
    fileprivate func updateBuddhasInHub(_ htmlString: NSString) {
        
//        saveToFile(htmlString as String)
        
        if htmlString == "" {
            return
        }
        
        do {
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTML(html: htmlString as String, encoding: .utf8)
            
            var tempBuddhas = [Buddha]()
            
            for item in doc.xpath("//div[@class='phimage']") {
                var name: String = ""
                var url: String = ""
                var imgUrl: String = ""
                var duration: String = ""
                let addTime:String = ""
                let user: String = ""
                
                if let a = item.xpath("div/a[@class='img ']").first {
                    url = a["href"] ?? ""
                
                    if let img = a.xpath("img").first {
                        name = img["title"] ?? ""
                        imgUrl = img["src"] ?? ""
                    }
                }
                
                if imgUrl == "" || !imgUrl.hasPrefix("http") {
                    continue
                }
                
                if let textArray = item.text?.components(separatedBy: "\n") {
                    for text in textArray {
                        duration = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if duration != "" {
                            break
                        }
                    }
                }
                
                let buddha = Buddha(name: name, url: url, imgUrl: imgUrl, duration: duration, addTime: addTime, user: user)
                
                if buddha.name != "" {
                    tempBuddhas.append(buddha)
                }
            }
            buddhas = tempBuddhas
            
        } catch let error {
            print(error)
        }
    }
    
    fileprivate func updateBuddhasIn91(_ htmlString: NSString) {

//        saveToFile(htmlString as String)
        
        if htmlString == "" {
            return
        }

        do {
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTML(html: htmlString as String, encoding: .utf8)
            
            // XPath queries
            
            var tempBuddhas = [Buddha]()
            
            for item in doc.xpath("//*[@class='listchannel']") {
                var name: String = ""
                var url: String = ""
                var imgUrl: String = ""
                var duration: String = ""
                var addTime:String = ""
                var user: String = ""
                if let img = item.xpath("div/a[@target='blank']/img").first {
                    name = img["title"] ?? ""
                    imgUrl = img["src"] ?? ""
                }
                if let urlItem = item.xpath("a[@target='blank']").first {
                    url = urlItem["href"] ?? ""
                }
                
                for (index, textItem) in item.xpath("text()").enumerated() {
                    if let text = textItem.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                        if text.contains(":") {
                            duration = text
                        }
                        if text.contains("ago") {
                            addTime = text
                        }
                        if (index == 8) {
                            user = text
                        }
                    }
                }
                let buddha = Buddha(name: name, url: url, imgUrl: imgUrl, duration: duration, addTime: addTime, user: user)
                tempBuddhas.append(buddha)
            }
            buddhas = tempBuddhas
            
        } catch let error {
            print(error)
        }
        
    }
    
    // MARK: BuddhaDetail
    func fetchBuddhaDetailIn91(_ buddha:Buddha, completion: @escaping QueryDetailResult) {
        guard let url = buddha.url else {
            DispatchQueue.main.async {
                completion(buddha, "url 为空")
            }
            return
        }
        
        setCookieIn91()
        
        Alamofire.request(url, headers: headers)
            .responseString { response in
                
                if let error = response.error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(buddha, error.localizedDescription)
                    }
                } else {
                    if let newBuddha = self.parseBuddhaIn91(buddha, response.result.value! as NSString){
                        DispatchQueue.main.async {
                            completion(newBuddha, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(buddha, "转换失败")
                        }
                    }
                }
        }
    }
    
    fileprivate func parseBuddhaIn91(_ buddha: Buddha, _ htmlString: NSString) -> Buddha? {
        if htmlString == "" {
            return nil
        }
        
        do {
            var newBuddha = buddha.mutableCopy()
            
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTML(html: htmlString as String, encoding: .utf8)
            
            // XPath queries
            if let nameItem = doc.xpath("//div[@id='viewvideo-title']/text()").first {
                newBuddha.name_zh = nameItem.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let videoItem = doc.xpath("//video[@id='vid']/source").first {
                newBuddha.videoUrl = videoItem["src"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if let imageItem = doc.xpath("//div[@class='example-video-container']/video").first {
                newBuddha.detailImgUrl = imageItem["poster"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if let addTimeItem = doc.xpath("//div[@id='videodetails-content']/span[@class='title']/text()").first {
                newBuddha.addTime_zh = addTimeItem.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if let infoItem = doc.xpath("//div[@class='boxPart']").first {
                let pointsItemString = infoItem.text
                var itemStringArray = [String]()
                for item in infoItem.xpath("span[@class='info']") {
                    let itemString = item.text
                    itemStringArray.append(itemString ?? "")
                }

                var points = pointsItemString?.components(separatedBy: itemStringArray[4])[1]
                points = points?.replacingOccurrences(of: "</div>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                newBuddha.points = points
            }
            
            return newBuddha
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func setCookieIn91() {
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
    
    func fetchBuddhaDetailInHub(_ buddha:Buddha, completion: @escaping QueryDetailResult) {
        guard let relativeUrl = buddha.url else {
            DispatchQueue.main.async {
                completion(buddha, "url 为空")
            }
            return
        }
        
        let url = "https://www.pornhub.com" + relativeUrl
        
        Alamofire.request(url, headers: headers)
            .responseString { response in
                
                if let error = response.error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(buddha, error.localizedDescription)
                    }
                } else {
                    if let newBuddha = self.parseBuddhaInHub(buddha, response.result.value! as NSString){
                        DispatchQueue.main.async {
                            completion(newBuddha, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(buddha, "转换失败")
                        }
                    }
                }
        }
    }
    
    fileprivate func parseBuddhaInHub(_ buddha: Buddha, _ htmlString: NSString) -> Buddha? {
        if htmlString == "" {
            return nil
        }
        
        saveToFile(htmlString as String)
        
        do {
            var newBuddha = buddha.mutableCopy()
            
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTML(html: htmlString as String, encoding: .utf8)
            
            // XPath queries
            if let scriptItem = doc.xpath("//div[@id='player']/script").first, let script = scriptItem.text?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "") {
                
                newBuddha.videoUrl = matchInfo(script, "videoUrl")
            }
            
            if newBuddha.videoUrl == "" {
                print(newBuddha)
            }
            
            newBuddha.detailImgUrl = newBuddha.imgUrl
            
            if let fromItem = doc.xpath("//div[@class='video-info-row']/div/a").first {
                newBuddha.user = fromItem.text
            }
            
            if let addOnItem = doc.xpath("//div[@class='video-info-row showLess']/span").reversed().first {
                newBuddha.addTime = addOnItem.text
                newBuddha.addTime_zh = addOnItem.text
            }
            
            if let pointsItem = doc.xpath("//div[@class='votes-count-container']/span").first {
                newBuddha.points = pointsItem.text
            }
            
            return newBuddha
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func matchInfo(_ string:String, _ pattern:String) -> String {
        var result = ""
        // - 1、创建规则
        let pattern1 = "(?<=\(pattern)\\\":\\\").*?(?=\\\")"
        // - 2、创建正则表达式对象
        let regex1 = try! NSRegularExpression(pattern: pattern1, options: NSRegularExpression.Options.caseInsensitive)
        // - 3、开始匹配A
        let res = regex1.matches(in: string, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, string.count))
        // 输出结果
        for checkingRes in res.reversed() {
            result = (string as NSString).substring(with: checkingRes.range)
            if result != "" {
                break
            }
        }
        result = result.replacingOccurrences(of: "\\", with: "")
        return result
    }
    
    private func setCookieInHub() {
        //创建一个HTTPCookie对象
        var props = Dictionary<HTTPCookiePropertyKey, Any>()
        props[HTTPCookiePropertyKey.name] = "platform"
        props[HTTPCookiePropertyKey.value] = "pc"
        props[HTTPCookiePropertyKey.name] = "ss"
        props[HTTPCookiePropertyKey.value] = "367701188698225489"
        props[HTTPCookiePropertyKey.name] = "bs"
        props[HTTPCookiePropertyKey.value] = ""
        props[HTTPCookiePropertyKey.name] = "RNLBSERVERID"
        props[HTTPCookiePropertyKey.value] = "ded6699"
        props[HTTPCookiePropertyKey.name] = "FastPopSessionRequestNumber"
        props[HTTPCookiePropertyKey.value] = "1"
        props[HTTPCookiePropertyKey.name] = "FPSRN"
        props[HTTPCookiePropertyKey.value] = "1"
        props[HTTPCookiePropertyKey.name] = "performance_timing"
        props[HTTPCookiePropertyKey.value] = "home"
        props[HTTPCookiePropertyKey.name] = "RNKEY"
        props[HTTPCookiePropertyKey.value] = "40859743*68067497:1190152786:3363277230:1"
        props[HTTPCookiePropertyKey.path] = "/"
        props[HTTPCookiePropertyKey.domain] = "91porn.com"
        let cookie = HTTPCookie(properties: props)
        let cstorage = HTTPCookieStorage.shared
        //        通过setCookie方法把Cookie保存起来
        cstorage.setCookie(cookie!)
    }
    
    private func saveToFile(_ htmlString: String) {
        let file = "data.html"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try (htmlString as String).write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                /* error handling here */
            }
        }
    }
}
