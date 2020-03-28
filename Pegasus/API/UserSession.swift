//
//  UserSession.swift
//  Pegasus
//
//  Created by yannmm on 20/3/28.
//  Copyright © 2020 rap. All rights reserved.
//

import Foundation
import PromiseKit

struct User {
    let accessToken: String
    let id: String
    let name: String
    let avatar: URL
}

extension UserSession {
    enum Error: LocalizedError {
        case weiboSSOFailed
        case unknown
        case invalidJson
    }
}

extension Notification.Name {
    static let onUserSessionChange = Notification.Name(rawValue: "onUserSessionChange")
}

class UserSession: NSObject {
    
    var isSignedin: Bool {
        return user != nil
    }
    
    static let current = UserSession()
    private let (promise, seal) = Promise<User>.pending()
    
    var user: User?
    
    func siginInIfNecessary() -> Promise<User> {
        if let u = user {
            seal.fulfill(u)
            return promise
        } else {
            let req = WBAuthorizeRequest.request() as! WBAuthorizeRequest
            req.redirectURI = "http://open.weibo.com/apps/3561756925/info/advanced"
            req.scope = "all"
            WeiboSDK.send(req)
            return promise
        }
    }
    
    func signOut() {
        user = nil
        NotificationCenter.default.post(name: .onUserSessionChange, object: nil, userInfo: nil)
    }
    
    func handleUrl(_ url: URL) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
}

extension UserSession: WBHttpRequestDelegate {
    func request(_ request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        print(result)
    }
}

extension UserSession: WeiboSDKDelegate {
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        print("收到微博的请求，但什么都不做")
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let r = response as? WBAuthorizeResponse, r.statusCode == .success {
            let req = URLRequest(url: URL(string: "https://api.weibo.com/2/users/show.json?access_token=\(r.accessToken!)&uid=\(r.userID!)")!)
            URLSession.shared.dataTask(with: req) { [unowned self] (data, _, error) in
                if let d = data, error == nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: d, options: []) as! [String: Any]
                        let name = json["screen_name"] as! String
                        let avatar = URL(string: json["avatar_large"] as! String)!
                        self.user = User(accessToken: r.accessToken, id: r.userID, name: name, avatar: avatar)
                        self.seal.fulfill(self.user!)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .onUserSessionChange, object: nil, userInfo: nil)
                        }
                    } catch {
                        self.seal.reject(error)
                    }
                } else if let e = error {
                    self.seal.reject(e)
                } else {
                    self.seal.reject(Error.unknown)
                }
            }.resume()
        } else {
            seal.reject(Error.weiboSSOFailed)
        }
    }
}

