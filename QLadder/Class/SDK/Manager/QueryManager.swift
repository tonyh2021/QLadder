//
//  QueryManager.swift
//  QLadder
//
//  Created by TonyHan on 2018/3/19.
//  Copyright © 2018年 TonyHan All rights reserved.
//

import Foundation
import Alamofire
import Fuzi

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
    
    private let pageSize = 20
    
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
        } else {
            url = "https://www.pornhub.com/recommended"
        }
        
        Alamofire.request(url)
            .responseString { response in
                
                if let error = response.error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(self.buddhas, error.localizedDescription)
                    }
                } else {
                    if buddhaType == .porn_91 {
                        self.updateBuddhasIn91(response.result.value! as NSString)
                    } else {
                        let file = "data.html"
                        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let fileURL = dir.appendingPathComponent(file)
                            //writing
                            do {
                                try (response.result.value! as String).write(to: fileURL, atomically: false, encoding: .utf8)
                            }
                            catch {
                                /* error handling here */
                            }
                        }
                        
//                        self.updateBuddhas(response.result.value! as NSString)
                    }
                    DispatchQueue.main.async {
                        completion(self.buddhas, nil)
                    }
                }
        }
    }
    
    fileprivate func updateBuddhasIn91(_ htmlString: NSString) {

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
                for durationItem in item.xpath("text()") {
                    let text = durationItem.rawXML.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.contains(":") {
                        duration = text
                    }
                    if text.contains("ago") {
                        addTime = text
                    }
                }
                if let userItem = item.xpath("a[@target='_parent']/text()").first {
                    user = userItem.rawXML
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
    func fetchBuddhaDetail(_ buddha:Buddha, completion: @escaping QueryDetailResult) {
        guard let url = buddha.url else {
            DispatchQueue.main.async {
                completion(buddha, "url 为空")
            }
            return
        }
        
        setWatchTimesCookie()
        
        Alamofire.request(url, headers: headers)
            .responseString { response in
                
                if let error = response.error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(buddha, error.localizedDescription)
                    }
                } else {
                    if let newBuddha = self.parseBuddha(buddha, response.result.value! as NSString){
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
    
    fileprivate func parseBuddha(_ buddha: Buddha, _ htmlString: NSString) -> Buddha? {
        if htmlString == "" {
            return nil
        }
        
        do {
            var newBuddha = buddha.mutableCopy()
            
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTMLDocument(string: htmlString as String, encoding: String.Encoding.utf8)
            
            // XPath queries
            if let nameItem = doc.xpath("//div[@id='viewvideo-title']/text()").first {
                newBuddha.name_zh = nameItem.rawXML.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let videoItem = doc.xpath("//video[@id='vid']/source").first {
                newBuddha.videoUrl = videoItem["src"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let imageItem = doc.xpath("//div[@class='example-video-container']/video").first {
                newBuddha.detailImgUrl = imageItem["poster"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let addTimeItem = doc.xpath("//div[@id='videodetails-content']/span[@class='title']/text()").first {
                newBuddha.addTime_zh = addTimeItem.rawXML.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let infoItem = doc.xpath("//div[@class='boxPart']").first {
                let pointsItemString = infoItem.rawXML
                var itemStringArray = [String]()
                for item in infoItem.xpath("span[@class='info']") {
                    let itemString = item.rawXML
                    itemStringArray.append(itemString)
                }

                var points = pointsItemString.components(separatedBy: itemStringArray[4])[1]
                points = points.replacingOccurrences(of: "</div>", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                newBuddha.points = points
            }
            
            return newBuddha
        } catch let error {
            print(error)
        }
        return nil
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
