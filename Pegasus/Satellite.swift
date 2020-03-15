//
//  locator.swift
//  Pegasus
//
//  Created by yannmm on 20/3/11.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapLocationKit
import PromiseKit

// MARK: - Wrapping delegate
//extension Satellite {
//    func locate() -> Promise<(CLLocation, AMapLocationReGeocode)> {
//        return proxy.promise
//    }
//}
//
//class Satellite: NSObject {
//    static let only = Satellite()
//
//    private let proxy = _AMapLocationManagerDelegateProxy()
//}

class Satellite: NSObject, AMapLocationManagerDelegate {
    
    static let only = Satellite()
    
    func locate() -> Promise<(CLLocation?, AMapLocationReGeocode?)> { return promise }
    
    func on() { atom.startUpdatingLocation() }
    func off() { atom.stopUpdatingLocation() }
    
    fileprivate let (promise, seal) = Promise<(CLLocation?, AMapLocationReGeocode?)>.pending()
    private var retainCycle: Satellite?
    
    private lazy var atom: AMapLocationManager = {
        let a = AMapLocationManager()
        a.distanceFilter = 200;
        a.locatingWithReGeocode = true
        a.delegate = self
        return a
    }()

    override init() {
        super.init()
        retainCycle = self
        let _ = promise.ensure { self.retainCycle = nil }
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        // @see https://stackoverflow.com/questions/57543233/what-happens-if-fulfill-is-called-twice-on-a-promise
        seal.fulfill((location, reGeocode))
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        seal.reject(error)
    }
}


// MARK: - One-time
//extension Satellite {
//    func locate() -> Promise<(CLLocation, AMapLocationReGeocode)> {
//        return Promise { seal in
//            self.compass.requestLocation(withReGeocode: true) { (loc, regeo, error) in
//                seal.resolve((loc!, regeo!), error)
//            }
//        }
//    }
//}
//
//class Satellite: NSObject {
//    static let only = Satellite()
//
//    private lazy var compass: AMapLocationManager = {
//        let a = AMapLocationManager()
//        a.distanceFilter = 200;
//        a.locatingWithReGeocode = true
//        return a
//    }()
//}
