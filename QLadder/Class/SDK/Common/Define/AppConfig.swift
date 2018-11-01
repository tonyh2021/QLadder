//
//  AppConfig.swift
//  QLadder
//
//  Created by TonyHan on 2017/11/21.
//  Copyright © 2017年 TonyHan All rights reserved.
//

import Foundation

public struct AppConfig {
    // App Name
    // App Version
    // App Build
    public static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    public static var fullVersion: String {
        return "\(AppConfig.version) Build \(AppConfig.build)"
    }
    
    public static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    public static var countryCode: String {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String ?? "US"
    }
    
    public static var languageCode: String {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String ?? "en"
    }
    
    public static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
    public static var isTestFlight: Bool {
        return isAppStoreReceiptSandbox && !hasEmbeddedMobileProvision
    }
    
    public static var isAppStore: Bool {
        if isAppStoreReceiptSandbox || hasEmbeddedMobileProvision {
            return false
        }
        return true
    }
    
    fileprivate static var isAppStoreReceiptSandbox: Bool {
        let b = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        NSLog("isAppStoreReceiptSandbox: \(b)")
        return b
    }
    
    fileprivate static var hasEmbeddedMobileProvision: Bool {
        let b = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        NSLog("hasEmbeddedMobileProvision: \(b)")
        return b
    }
    
}
