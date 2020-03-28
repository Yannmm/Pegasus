//
//  SigninViewController.swift
//  Pegasus
//
//  Created by yannmm on 20/3/28.
//  Copyright © 2020 rap. All rights reserved.
//

import Foundation
import PromiseKit

class SigninViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(logoLabel)
        view.addSubview(signinButton)
        
        logoLabel.lego.build { (b) in
            b.centerY.equalToSuperview().offset(-30.0)
            b.centerX.equalToSuperview()
        }
        
        signinButton.lego.build { (b) in
            b.centerX.equalToSuperview()
            b.top.equalTo(logoLabel.lego.bottom).offset(20.0)
            b.size.equalTo(CGSize(width: 120.0, height: 60.0))
        }
    }
    
    @objc private func signin() {
        firstly {
            UserSession.current.siginInIfNecessary()
        }.done {
            print($0)
            self.dismiss(animated: true, completion: nil)
        }.catch {
            print($0)
        }
    }
    
    private lazy var logoLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 45.0)
        l.text = "🌈 乐乐去旅行 🌈"
        return l
    }()
    
    private lazy var signinButton: UIButton = {
        let b = UIButton(type: .custom)
        b.adjustsImageWhenHighlighted = false
        b.setTitle("请登录", for: .normal)
        b.setTitleColor(UIColor.white, for: .normal)
        b.addTarget(self, action: #selector(signin), for: .touchUpInside)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        b.backgroundColor = UIColor.lightGray
        b.layer.cornerRadius = 5.0
        b.layer.masksToBounds = true
        return b
    }()
}
