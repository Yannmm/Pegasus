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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.setZoomLevel(14, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSessionChange(_:)), name: .onUserSessionChange, object: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "登陆", style: .done, target: self, action: #selector(manageSession))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "天气", style: .done, target: self, action: #selector(weather))
        
        self.navigationItem.title = "附近景点"
        
        view.addSubview(mapView)
        mapView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
        
        searchIt()
    }
    
    @objc private func onUserSessionChange(_ noti: Notification) {
        let title = UserSession.current.isSignedin ? UserSession.current.user!.name : "登陆"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(manageSession))
    }
    
    @objc private func weather() {
        firstly {
            Cloudy().tell()
        }.done { [unowned self] live in
            var message: String! = live.weather
            message += "\n"
            message += "\(live.temperature!)℃"
            message += "\n"
            message += "\(live.windDirection!)风" + "\(live.windPower!)级"
            message += "\n"
            message += "湿度\(live.humidity!)%"
            let alert = UIAlertController(title: live.city, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "👌", style: .default, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }.catch { (error) in
            print(error)
        }
    }

    @objc private func searchIt() {
        Radar().around().done {
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
        if let a = annotation as? PoiAnnotation {
            var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "123321") as? MapMarkerAnnotationView
            if marker == nil {
                marker = MapMarkerAnnotationView(annotation: a, reuseIdentifier: "123321")
            }
            marker?.onAccessoryViewTap = {
                print("开启这个点的导航")
                Compass.only.route(to: a)
            }
            return marker!
        }
        return nil
    }
}

extension ViewController {
    @objc private func manageSession() {
        if !UserSession.current.isSignedin {
            present(SigninViewController(), animated: true, completion: nil)
        } else {
            UserSession.current.signOut()
        }
    }
}
