//
//  AMapPOI+Helper.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapSearchKit

extension AMapPOI {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(self.location!.latitude),
            longitude: CLLocationDegrees(self.location!.longitude))
    }
}
