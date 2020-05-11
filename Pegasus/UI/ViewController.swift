//
//  ViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/3/8.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapNaviKit
import AMapSearchKit
import PromiseKit



class ViewController: UIViewController {
    
    private lazy var mapView: MAMapView = {
        let map = MAMapView()
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.delegate = self
        return map
    }()
    
    // 视图即将显示时调用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.setZoomLevel(14, animated: animated)
    }

    // 视图加载时调用
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        self.navigationItem.title = "附近景点"
        
        // 添加地图
        view.addSubview(mapView)
        // 将地图布局
        mapView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
        
        // 第一次搜索，搜索附近 poi 点
        searchIt()
    }

    @objc private func searchIt() {
        // Radar 是 poi 服务
        // around() 表示搜索附近 poi
        // done 表示完成的回调
        Radar().around().done {
            // $0 是结果，将其转换为地图所需的标注对象
            // map 表示将一个数组转换为另一个数组，如 [int].map { i in double(i) } -> [double]
            let k = $0.map { $0.images }.compactMap { $0 }.flatMap { $0 }
            print(k)
            let annos = $0.map { p -> PoiAnnotation in
                return PoiAnnotation(title: p.name,
                                      subtitle: p.address,
                                      coordinate: p.coordinate,
                                      poiid: p.uid)
            }
            // 将标注传给地图
            self.mapView.addAnnotations(annos)
        }.catch { // catch 表示捕获错误，$0 是错误
            print($0)
        }
    }
}

extension ViewController: MAMapViewDelegate {
    // 地图获取标注对象后，会调用这个方法，要求按照标注创建地图上的标注视图并返回
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if let a = annotation as? PoiAnnotation {
            var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "123321") as? MapMarkerAnnotationView
            if marker == nil {
                marker = MapMarkerAnnotationView(annotation: a, reuseIdentifier: "123321")
            }
            // marker 的点击时间回调，点击开启导航
            // Compass 是导航服务
            // route 表示开启导航，显示线路
            marker?.onAccessoryViewTap = {
                print("开启这个点的导航")
                Compass.only.route(to: a)
            }
            return marker!
        }
        return nil
    }
}
