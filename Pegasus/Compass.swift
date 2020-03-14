//
//  Compass.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapNaviKit

class Compass: NSObject {
    static let only = Compass()
    
    
    func tttt(_ coordinate: CLLocationCoordinate2D) {
        
//        let from = AMapNaviPoint(coordinate: Satellite.only.latestLocation.coordinate)
//        let to = AMapNaviPoint(coordinate: coordinate)
//
//
//        let config = AMapNaviCompositeUserConfig.init()
//        config.setRoutePlanPOIType(AMapNaviRoutePlanPOIType.start, location: from, name: "我的位置", poiId: nil)
//        config.setRoutePlanPOIType(AMapNaviRoutePlanPOIType.end, location: to, name: "终点", poiId: nil)
//        engine.presentRoutePlanViewController(withOptions: config)
    }
    
    func route(to destination: MAPointAnnotation, poiid: String) {
        let config = AMapNaviCompositeUserConfig.init()
        config.setRoutePlanPOIType(AMapNaviRoutePlanPOIType.end, location: AMapNaviPoint(coordinate: destination.coordinate), name: destination.title, poiId: poiid)
        
        engine.presentRoutePlanViewController(withOptions: config)
    }
    
    private lazy var engine: AMapNaviCompositeManager = {
        let m = AMapNaviCompositeManager()
        m.delegate = self
        return m
    }()
}

extension Compass: AMapNaviCompositeManagerDelegate {
    func compositeManager(onCalculateRouteSuccess compositeManager: AMapNaviCompositeManager) {
        print("算路成功")
    }
}
