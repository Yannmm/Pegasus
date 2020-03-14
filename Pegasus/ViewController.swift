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
        
        searchIt()
    }

    @objc private func searchIt() {
//        let request = AMapPOIKeywordsSearchRequest()
//        request.keywords = "景点"
//        request.requireExtension = true
//        request.city = "成都"
//
//        request.cityLimit = true
//        request.requireSubPOIs = true
//
//        search.aMapPOIKeywordsSearch(request)
        
        searcher.surroundings { [unowned self] (pois) in
            let annos = pois.map { p -> MAPointAnnotation in
                let a = MAPointAnnotation()
                a.coordinate = p.coordinate
                a.title = p.name
                a.subtitle = p.address
                return a
            }
            self.mapView.addAnnotations(annos)
        }
    }
    
    private let searcher = PoiSearcher()
}

extension ViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        guard annotation.title != "当前位置" else { return nil }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
            
//            let idx = annotations.index(of: annotation as! MAPointAnnotation)
            annotationView!.pinColor = .green
            
            return annotationView!
        }
        
        return nil
    }
}
