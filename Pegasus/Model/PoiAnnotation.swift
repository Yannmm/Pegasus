//
//  PoiAnnotation.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapNaviKit

class PoiAnnotation: MAPointAnnotation {
    let poiid: String
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, poiid: String) {
        self.poiid = poiid
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}
