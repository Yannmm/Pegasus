//
//  ViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/3/8.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapNaviKit
import AMapLocationKit


class ViewController: UIViewController {
    
    private lazy var mapView: MAMapView = {
        let map = MAMapView()
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.delegate = self
        return map
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.setZoomLevel(13, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "搜索", style: .done, target: self, action: #selector(searchIt))
        
        view.addSubview(mapView)
        mapView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
        
//        searchIt()
    }

    @objc private func searchIt() {

        Radar().surroundings().done {
            let annos = $0.map { p -> PoiAnnotation in
                return PoiAnnotation(title: p.name,
                                      subtitle: p.address,
                                      coordinate: p.coordinate,
                                      poiid: p.uid)
            }
            self.mapView.addAnnotations(annos)
        }.catch {
            print($0)
        }
    }
}

extension ViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        guard annotation.title != "当前位置" else { return nil }
        
        if let a = annotation as? PoiAnnotation {
            var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "123321") as? MapMarkerAnnotationView
            if marker == nil {
                marker = MapMarkerAnnotationView(annotation: a, reuseIdentifier: "123321")
            }
            
            marker?.onAccessoryViewTap = {
                print("开启这个点的导航")
//                Compass.only.tttt(annotation.coordinate)
                Compass.only.route(to: a, poiid: a.poiid)
            }
            
            
            return marker!
        }
        
        return nil
    }
}
