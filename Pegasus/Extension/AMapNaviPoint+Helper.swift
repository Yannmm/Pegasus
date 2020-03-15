//
//  AMapNaviPoint+Helper.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapNaviKit

extension AMapNaviPoint {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        latitude = CGFloat(coordinate.latitude)
        longitude = CGFloat(coordinate.longitude)
    }
}
