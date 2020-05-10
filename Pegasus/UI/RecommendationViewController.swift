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

class RecommendationViewController: UIViewController {
    
    var side: CGFloat {
        return (UIScreen.main.bounds.size.width - 10.0 * 2 - 15.0 * 2) / 3.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f9f9f9")
        view.addSubview(scrollView)
        scrollView.addSubview(hotspotLabel)
        scrollView.addSubview(hotspotCollectionView)
        scrollView.addSubview(nearbyLabel)
        scrollView.addSubview(nearbyCollectionView)
        
        scrollView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
        
        hotspotLabel.lego.build { (b) in
            b.top.equalTo(scrollView.safeAreaLayoutGuide).offset(20.0)
            b.leading.equalToSuperview().offset(15.0)
        }
        
        hotspotCollectionView.lego.build { (b) in
            b.top.equalTo(hotspotLabel.lego.bottom).offset(5.0)
            b.leading.trailing.equalToSuperview()
            b.height.equalTo(side * 2 + 11.0)
            b.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        nearbyLabel.lego.build { (b) in
            b.top.equalTo(hotspotCollectionView.lego.bottom).offset(30.0)
            b.leading.equalToSuperview().offset(15.0)
        }
        
        nearbyCollectionView.lego.build { (b) in
            b.top.equalTo(nearbyLabel.lego.bottom).offset(5.0)
            b.leading.trailing.equalToSuperview()
            b.height.equalTo(side)
            b.width.equalTo(UIScreen.main.bounds.size.width)
            b.bottom.equalTo(scrollView.lego.bottom).offset(-20.0)
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
//        s.showsVerticalScrollIndicator = false
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
    
    private lazy var hotspotLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18.0)
        l.textColor = UIColor.darkText
        l.text = "热门景点"
        return l
    }()
    
    private lazy var nearbyLabel: UILabel = {
         let l = UILabel()
         l.font = UIFont.systemFont(ofSize: 18.0)
         l.textColor = UIColor.darkText
         l.text = "附近景点"
         return l
     }()

}

extension RecommendationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell.RecommendationViewController", for: indexPath)
        return cell
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
                b.centerX.equalToSuperview()
                b.bottom.equalToSuperview().offset(-5.0)
            }
            
        }
        
        private lazy var imageView: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFill
            return v
        }()
        
        private lazy var nameLabel: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0
            l.font = UIFont.systemFont(ofSize: 18.0)
            l.textColor = UIColor.darkText
//            l.text = "这是什么"
            return l
        }()
    }
}
