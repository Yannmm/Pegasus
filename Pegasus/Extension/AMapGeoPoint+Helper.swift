//
//  AMapGeoPoint+Helper.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapSearchKit

extension AMapGeoPoint {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        latitude = CGFloat(coordinate.latitude)
        longitude = CGFloat(coordinate.longitude)
    }
}
