//
//  locator.swift
//  Pegasus
//
//  Created by yannmm on 20/3/11.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapLocationKit

class Locator: NSObject {
    
    static let only = Locator()
    
    var latestLocation: CLLocation!
    
    func on() {
        compass.startUpdatingLocation()
    }
    
    func off() {
        compass.stopUpdatingLocation()
    }
    
    private lazy var compass: AMapLocationManager = {
        let a = AMapLocationManager()
        a.delegate = self
        a.distanceFilter = 200;
        a.locatingWithReGeocode = true
        return a
    }()
}

extension Locator: AMapLocationManagerDelegate {
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        latestLocation = location
        print(reGeocode)
    }
}
