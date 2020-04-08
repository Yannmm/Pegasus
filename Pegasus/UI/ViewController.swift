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
        // 注册用户登入/登出通知
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSessionChange(_:)), name: .onUserSessionChange, object: nil)
        // 导航栏左侧按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "登陆", style: .done, target: self, action: #selector(manageSession))
        // 导航栏右侧按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "天气", style: .done, target: self, action: #selector(weather))
        
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
    
    // 用户登陆状态发生变化
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
        // Radar 是 poi 服务
        // around() 表示搜索附近 poi
        // done 表示完成的回调
        Radar().around().done {
            // $0 是结果，将其转换为地图所需的标注对象
            // map 表示将一个数组转换为另一个数组，如 [int].map { i in double(i) } -> [double]
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

extension ViewController {
    // 导航栏左侧按钮动作方法
    @objc private func manageSession() {
        if !UserSession.current.isSignedin { // 如果未登陆，就呈现登陆界面
            present(SigninViewController(), animated: true, completion: nil)
        } else { // 如果已经登陆，则登出
            UserSession.current.signOut()
        }
    }
}
