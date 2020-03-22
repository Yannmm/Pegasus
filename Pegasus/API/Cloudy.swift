//
//  Cloudy.swift
//  Pegasus
//
//  Created by yannmm on 20/3/15.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapSearchKit
import PromiseKit

class Cloudy {
    func tell() -> Promise<AMapLocalWeatherLive> {
        return firstly {
            Satellite.only.locate()
        }.then { tuple in
            _AMapWeatherSearcher().go(tuple.1?.city ?? "成都")
        }
    }
}

private class _AMapWeatherSearcher: NSObject, AMapSearchDelegate {
    func go(_ city: String) -> Promise<AMapLocalWeatherLive> {
        let req:AMapWeatherSearchRequest! = AMapWeatherSearchRequest.init()
        req.city = city
        req.type = AMapWeatherType.live
        search.aMapWeatherSearch(req)
        return promise
    }
    
    private let (promise, seal) = Promise<AMapLocalWeatherLive>.pending()
    private var retainCycle: _AMapWeatherSearcher?
    private let search = AMapSearchAPI()!

    override init() {
        super.init()
        retainCycle = self
        search.delegate = self // does not retain hence the `retainCycle` property

        let _ = promise.ensure { self.retainCycle = nil }
    }
    
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        seal.fulfill(response.lives.first!)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        seal.reject(error)
    }
}
