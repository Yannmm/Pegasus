//
//  PoiTableViewCell.swift
//  Pegasus
//
//  Created by yannmm on 20/3/15.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit
import AMapSearchKit

class PoiTableViewCell: UITableViewCell {
    
    var poi: AMapPOI? {
        didSet {
            guard let p = poi else { return }
            nameLabel.text = p.name
            addressLabel.text = p.address
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
        
        nameLabel.lego.build { (b) in
            b.top.equalToSuperview().offset(10.0)
            b.leading.equalToSuperview().offset(20.0)
        }
        
        addressLabel.lego.build { (b) in
            b.top.equalTo(nameLabel.lego.bottom).offset(5.0)
            b.leading.equalTo(nameLabel)
            b.bottom.equalToSuperview().offset(-10.0)
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16.0)
        l.textColor = UIColor.darkText
        l.text = "这是什么"
        return l
    }()
    
    private lazy var addressLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14.0)
        l.textColor = UIColor.lightGray
        l.text = "这是地址"
        return l
    }()
}
