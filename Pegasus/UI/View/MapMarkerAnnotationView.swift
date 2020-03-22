//
//  MapMarkerAnnotationView.swift
//  Pegasus
//
//  Created by yannmm on 20/3/14.
//  Copyright © 2020 rap. All rights reserved.
//

import AMapNaviKit

class MapMarkerAnnotationView: MAPinAnnotationView {
    
    var onAccessoryViewTap: (() -> Void)?
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        image = UIImage(named: "map_pin")
        calloutOffset = .init(x: 0.0, y: -5.0)
        canShowCallout = true
        animatesDrop = true
        isDraggable = true
        rightCalloutAccessoryView = rightButton
    }
    
    @objc private func tap() {
        onAccessoryViewTap?()
    }
    
    private lazy var rightButton: UIButton = {
        let b = UIButton(type: UIButton.ButtonType.detailDisclosure)
        b.addTarget(self, action: #selector(tap), for: .touchUpInside)
        return b
    }()
}
