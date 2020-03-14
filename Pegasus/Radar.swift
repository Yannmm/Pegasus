//
//  poi_searcher.swift
//  Pegasus
//
//  Created by yannmm on 20/3/11.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapSearchKit
import PromiseKit

class Radar: NSObject {
    
    func surroundings() -> Promise<[AMapPOI]> {
        return firstly {
            Satellite.only.locate()
        }.then { tuple in
            _AMapPoiSearchDelegateProxy().go(tuple.0)
        }
    }
    
    
//    func surroundings(then completionHandler: @escaping ([AMapPOI]) -> Void) {
//
//
//        let req = AMapPOIAroundSearchRequest()
//        req.location = AMapGeoPoint.location(withLatitude: CGFloat(Satellite.only.latestLocation.coordinate.latitude), longitude: CGFloat(Satellite.only.latestLocation.coordinate.longitude))
//        req.keywords = "风景名胜"
//        req.sortrule = 0
//        req.requireExtension = true
//
//        launcher.aMapPOIAroundSearch(req)
//    }
}


private class _AMapPoiSearchDelegateProxy: NSObject, AMapSearchDelegate {
    func go(_ location: CLLocation) -> Promise<[AMapPOI]> {
        let req = AMapPOIAroundSearchRequest()
        req.location = AMapGeoPoint(coordinate: location.coordinate)
        req.keywords = "风景名胜"
        req.sortrule = 0
        req.requireExtension = true
        
        search.aMapPOIAroundSearch(req)
        
        return promise
    }
    
    private let (promise, seal) = Promise<[AMapPOI]>.pending()
    private var retainCycle: _AMapPoiSearchDelegateProxy?
    private let search = AMapSearchAPI()!

    override init() {
        super.init()
        retainCycle = self
        search.delegate = self // does not retain hence the `retainCycle` property

        let _ = promise.ensure { self.retainCycle = nil }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        seal.fulfill(response.pois)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        seal.reject(error)
    }
}


//        let request = AMapPOIKeywordsSearchRequest()
//        request.keywords = "景点"
//        request.requireExtension = true
//        request.city = "成都"
//
//        request.cityLimit = true
//        request.requireSubPOIs = true
//
//        search.aMapPOIKeywordsSearch(request)
