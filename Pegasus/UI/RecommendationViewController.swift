//
//  RecommendationViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/5/10.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapSearchKit
import Kingfisher
import PromiseKit

class RecommendationViewController: UIViewController {
    
    var side: CGFloat {
        return (UIScreen.main.bounds.size.width - 10.0 * 2 - 15.0 * 2) / 3.0
    }
    
    private var hotspotPois = [AMapPOI]()
    private var nearbyPois = [AMapPOI]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        Satellite.only.locate().done { [unowned self] in
            self.navigationItem.title = $0.1?.city ?? "成都"
        }.catch { (error) in
            print(error)
        }
        
        Radar().city().done { [unowned self] in
            self.hotspotPois = $0
            self.hotspotCollectionView.reloadData()
        }.catch { (error) in
            print(error)
        }
        
        Radar().around().done { [unowned self] in
            self.nearbyPois = $0
            self.nearbyCollectionView.reloadData()
        }.catch { (error) in
            print(error)
        }
        
        // 注册用户登入/登出通知
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSessionChange(_:)), name: .onUserSessionChange, object: nil)
        // 导航栏左侧按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "登陆", style: .done, target: self, action: #selector(manageSession))
        // 导航栏右侧按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "天气", style: .done, target: self, action: #selector(weather))
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#f9f9f9")
        view.addSubview(scrollView)
        scrollView.addSubview(hotspotButton)
        scrollView.addSubview(hotspotCollectionView)
        scrollView.addSubview(nearbyButton)
        scrollView.addSubview(nearbyCollectionView)
        
        scrollView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
        
        hotspotButton.lego.build { (b) in
            b.top.equalTo(scrollView.safeAreaLayoutGuide).offset(20.0)
            b.leading.equalToSuperview().offset(15.0)
        }
        
        hotspotCollectionView.lego.build { (b) in
            b.top.equalTo(hotspotButton.lego.bottom).offset(5.0)
            b.leading.trailing.equalToSuperview()
            b.height.equalTo(side * 2 + 11.0)
            b.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        nearbyButton.lego.build { (b) in
            b.top.equalTo(hotspotCollectionView.lego.bottom).offset(30.0)
            b.leading.equalToSuperview().offset(15.0)
        }
        
        nearbyCollectionView.lego.build { (b) in
            b.top.equalTo(nearbyButton.lego.bottom).offset(5.0)
            b.leading.trailing.equalToSuperview()
            b.height.equalTo(side)
            b.width.equalTo(UIScreen.main.bounds.size.width)
            b.bottom.equalTo(scrollView.lego.bottom).offset(-20.0)
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        return s
    }()
    
    private lazy var hotspotCollectionView: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 10.0
        l.minimumInteritemSpacing = 10.0
        l.itemSize = CGSize(width: side, height: side)
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: l)
        c.backgroundColor = UIColor(hex: "#f9f9f9")
        c.contentInsetAdjustmentBehavior = .never
        c.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell.RecommendationViewController")
        c.delegate = self
        c.dataSource = self
        c.showsHorizontalScrollIndicator = false
        return c
    }()
    
    private lazy var nearbyCollectionView: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 10.0
        l.minimumInteritemSpacing = 10.0
        l.itemSize = CGSize(width: side, height: side)
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: l)
        c.backgroundColor = UIColor(hex: "#f9f9f9")
        c.contentInsetAdjustmentBehavior = .never
        c.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell.RecommendationViewController")
        c.delegate = self
        c.dataSource = self
        c.showsHorizontalScrollIndicator = false
        return c
    }()
    
    private lazy var hotspotButton: UIButton = {
        let b = UIButton(type: .custom)
        b.adjustsImageWhenHighlighted = false
        b.setTitle("热门景点 >", for: .normal)
        b.setTitleColor(UIColor.darkGray, for: .normal)
        b.addTarget(self, action: #selector(hotspotButtonTapped), for: .touchUpInside)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        return b
    }()
    
    @objc private func hotspotButtonTapped() {
        let vc = PoiListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private lazy var nearbyButton: UIButton = {
        let b = UIButton(type: .custom)
        b.adjustsImageWhenHighlighted = false
        b.setTitle("附近景点 >", for: .normal)
        b.setTitleColor(UIColor.darkGray, for: .normal)
        b.addTarget(self, action: #selector(nearbyButtonTapped), for: .touchUpInside)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        return b
    }()
    
    @objc private func nearbyButtonTapped() {
        let vc = ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension RecommendationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === hotspotCollectionView {
            return hotspotPois.count
        } else if collectionView == nearbyCollectionView {
            return nearbyPois.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === hotspotCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell.RecommendationViewController", for: indexPath) as! CollectionViewCell
            cell.poi = hotspotPois[indexPath.row]
            return cell
        } else if collectionView == nearbyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell.RecommendationViewController", for: indexPath) as! CollectionViewCell
            cell.poi = nearbyPois[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell.RecommendationViewController", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == hotspotCollectionView {
            let p = hotspotPois[indexPath.row]
            Compass.only.route(to: p)
        } else if collectionView == nearbyCollectionView {
            let p = nearbyPois[indexPath.row]
            Compass.only.route(to: p)
        }
    }
}

extension RecommendationViewController {
    class CollectionViewCell: UICollectionViewCell {
        
        var poi: AMapPOI? {
            didSet {
                guard let p = poi else { return }
                nameLabel.text = p.name
                if let s = p.images.first?.url, let url = URL(string: s) {
                    imageView.kf.setImage(with: url)
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        private func setupViews() {
            contentView.backgroundColor = UIColor.random
            contentView.addSubview(imageView)
            contentView.addSubview(nameLabel)
            
            imageView.lego.build { (b) in
                b.edges.equalToSuperview()
            }
            
            nameLabel.lego.build { (b) in
                b.leading.trailing.equalToSuperview()
                b.bottom.equalToSuperview().offset(-5.0)
            }
        }
        
        private lazy var imageView: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true
            return v
        }()
        
        private lazy var nameLabel: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0
            l.font = UIFont.boldSystemFont(ofSize: 18.0)
            l.adjustsFontSizeToFitWidth = true
            l.textColor = UIColor.white
            return l
        }()
    }
}

extension RecommendationViewController {
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
    
    // 导航栏左侧按钮动作方法
    @objc private func manageSession() {
        if !UserSession.current.isSignedin { // 如果未登陆，就呈现登陆界面
            present(SigninViewController(), animated: true, completion: nil)
        } else { // 如果已经登陆，则登出
            UserSession.current.signOut()
        }
    }
}
