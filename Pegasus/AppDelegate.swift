//
//  AppDelegate.swift
//  Pegasus
//
//  Created by yannmm on 20/3/8.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapFoundationKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 高德地图启动项
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared()?.apiKey = "050a433a6ce80ce4fb2764d6e1247ff7"
        
        // 微博 SDK 启动项
        // @see https://github.com/sinaweibosdk/weibo_ios_sdk/issues/417
        WeiboSDK.registerApp("3561756925")
        WeiboSDK.enableDebugMode(true)
        
        // 启动定位服务
        Satellite.only.on()
        
        // 跳转至根控制器 -> ViewController.swift
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return UserSession.current.handleUrl(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return UserSession.current.handleUrl(url)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return UserSession.current.handleUrl(url)
    }
}
