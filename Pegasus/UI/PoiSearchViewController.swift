//
//  RecommendationViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/5/10.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapSearchKit

class PoiSearchViewController: UIViewController {
    private let throttler = Throttler(minimumDelay: 0.5)
    private var pois = [AMapPOI]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        tableView.lego.build { (b) in
            b.edges.equalToSuperview()
        }
    }

    private lazy var searchBar: UISearchBar = {
        let b = UISearchBar()
        b.delegate = self
        b.placeholder = "搜索景点"
        b.searchBarStyle = .prominent
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.cgColor
        return b
    }()
    
    private lazy var tableView: UITableView = {
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        t.register(PoiTableViewCell.self, forCellReuseIdentifier: "PoiTableViewCell")
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 50.0
        return t
    }()
}

extension PoiSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 0 else {
            return
        }
        throttler.throttle {
            Radar().keyword(searchText).done { [unowned self] in
                self.pois = $0
                self.tableView.reloadData()
            }.catch { (error) in
                print(error)
            }
        }
    }
}

extension PoiSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoiTableViewCell", for: indexPath) as! PoiTableViewCell
        cell.poi = pois[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let p = pois[indexPath.row]
        Compass.only.route(to: p)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
