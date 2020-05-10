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
    
    // 根据定位寻找周围 poi 点，返回一个 promise，携带的数据结构为 [AMapPOI]
    func around() -> Promise<[AMapPOI]> {
        return firstly { // firstly 表示首先
            // 首先获取定位
            // Satellite 是定位服务，locate() 表示获取位置
            Satellite.only.locate()
        }.then { tuple in
            // tuple.0 是坐标点
            // _AMapAroundPoiSearcher 是执行搜索的具体类
            _AMapAroundPoiSearcher().go(tuple.0!)
        }
    }
    
    // 寻找当前城市的 poi 点
    func city() -> Promise<[AMapPOI]> {
        return firstly {
            // 还是首先获取定位
            Satellite.only.locate()
        }.then { tuple in
            // tuple.1?.city 是城市
            // _AMapCityPoiSearcher 是执行搜索的具体类
            _AMapCityPoiSearcher().go(tuple.1?.city ?? "成都")
        }
    }
    
    // 根据关键字查询当前城市旅游景点
    func keyword(_ text: String) -> Promise<[AMapPOI]> {
        return firstly {
            // 还是首先获取定位
            Satellite.only.locate()
        }.then { tuple in
            // tuple.1?.city 是城市
            // _AMapCityPoiSearcher 是执行搜索的具体类
            _AMapKeywordPoiSearcher().go(text, tuple.1?.city ?? "成都")
        }
    }
}

private class _AMapKeywordPoiSearcher: NSObject, AMapSearchDelegate {
    func go(_ keyword: String, _ city: String) -> Promise<[AMapPOI]> {
        let req = AMapPOIKeywordsSearchRequest()
        req.keywords = keyword
        req.types = "风景名胜"
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
    private var retainCycle: _AMapKeywordPoiSearcher?
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
