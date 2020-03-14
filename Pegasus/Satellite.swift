//
//  locator.swift
//  Pegasus
//
//  Created by yannmm on 20/3/11.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapLocationKit
import PromiseKit

extension Satellite {
    func locate() -> Promise<(CLLocation, AMapLocationReGeocode)> {
        return Promise { seal in
            self.compass.requestLocation(withReGeocode: true) { (loc, regeo, error) in
                seal.resolve((loc!, regeo!), error)
            }
        }
    }
}

class Satellite: NSObject {
    static let only = Satellite()
    
    private lazy var compass: AMapLocationManager = {
        let a = AMapLocationManager()
        a.distanceFilter = 200;
        a.locatingWithReGeocode = true
        return a
    }()
}
