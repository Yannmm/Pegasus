//
//  PoiListViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/3/15.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapSearchKit

class PoiListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        self.navigationItem.title = "成都"
        
        tableView.lego.build { (b) in
           b.edges.equalToSuperview()
        }
        
//        Satellite.only.locate().done { tuple in
//            self.parent?.navigationItem.title = tuple.1?.city
//        }.catch { (error) in
//            print(error)
//        }
        
        Radar().city().done { [unowned self] in
            self.pois = $0
            self.tableView.reloadData()
        }.catch { (error) in
            print(error)
        }
    }
    
    private var pois = [AMapPOI]()
    
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

extension PoiListViewController: UITableViewDataSource, UITableViewDelegate {
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
        
//        Compass.only.route(to: a, poiid: a.poiid)
    }
}
