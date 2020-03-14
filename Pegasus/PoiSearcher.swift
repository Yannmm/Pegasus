//
//  poi_searcher.swift
//  Pegasus
//
//  Created by yannmm on 20/3/11.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapSearchKit

class PoiSearcher: NSObject {
    private var completionHandler: (([AMapPOI]) -> Void)?
    
    func surroundings(then completionHandler: @escaping ([AMapPOI]) -> Void) {
        self.completionHandler = completionHandler
        
        let req = AMapPOIAroundSearchRequest()
        req.location = AMapGeoPoint.location(withLatitude: CGFloat(Locator.only.latestLocation.coordinate.latitude), longitude: CGFloat(Locator.only.latestLocation.coordinate.longitude))
        req.keywords = "风景名胜"
        req.sortrule = 0
        req.requireExtension = true

        launcher.aMapPOIAroundSearch(req)
    }
    
    private lazy var launcher: AMapSearchAPI  = {
        let s = AMapSearchAPI()!
        s.delegate = self
        return s
    }()
}

extension PoiSearcher: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        completionHandler?(response.pois)
    }
}
