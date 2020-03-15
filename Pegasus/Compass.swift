//
//  Compass.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapNaviKit

protocol Poi {
    var coordinate: CLLocationCoordinate2D { get }
    var alias: String { get }
    var id: String { get }
}

class Compass: NSObject {
    static let only = Compass()
    
    func route(to poi: Poi) {
        let config = AMapNaviCompositeUserConfig.init()
        config.setRoutePlanPOIType(AMapNaviRoutePlanPOIType.end, location: AMapNaviPoint(coordinate: poi.coordinate), name: poi.alias, poiId: poi.id)
        
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
