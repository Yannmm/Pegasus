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
    
    func around() -> Promise<[AMapPOI]> {
        return firstly {
            Satellite.only.locate()
        }.then { tuple in
            _AMapAroundPoiSearcher().go(tuple.0!)
        }
    }
    
    func city() -> Promise<[AMapPOI]> {
        return firstly {
            Satellite.only.locate()
        }.then { tuple in
            _AMapCityPoiSearcher().go(tuple.1?.city ?? "成都")
        }
    }
}

private class _AMapCityPoiSearcher: NSObject, AMapSearchDelegate {
    func go(_ city: String) -> Promise<[AMapPOI]> {
        let req = AMapPOIKeywordsSearchRequest()
        req.keywords = "风景名胜"
        req.requireExtension = true
        req.city = city
        req.cityLimit = true
        req.requireSubPOIs = true
        req.offset = 50
        req.page = 1
        search.aMapPOIKeywordsSearch(req)
        return promise
    }
    
    private let (promise, seal) = Promise<[AMapPOI]>.pending()
    private var retainCycle: _AMapCityPoiSearcher?
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

private class _AMapAroundPoiSearcher: NSObject, AMapSearchDelegate {
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
    private var retainCycle: _AMapAroundPoiSearcher?
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