//
//  UIColor+Helper.swift
//  Pegasus
//
//  Created by yannmm on 20/5/10.
//  Copyright © 2020 rap. All rights reserved.
//

import UIKit

public extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }
}

public extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

public extension UIColor {
    convenience init(hex: String) {
        var r: CGFloat = 1.0
        var g: CGFloat = 1.0
        var b: CGFloat = 1.0
        var a: CGFloat = 1.0

        guard hex.hasPrefix("#") else {
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }

        let cstring = String(hex.suffix(hex.count - 1))
        let scanner = Scanner(string: cstring)

        var hdigit: UInt32 = 0
        switch cstring.count {
        case 6: // RRGGBB
            if scanner.scanHexInt32(&hdigit) {
                r = CGFloat((hdigit & 0xff0000) >> 16) / 255
                g = CGFloat((hdigit & 0x00ff00) >> 08) / 255
                b = CGFloat((hdigit & 0x0000ff) >> 00) / 255
                a = 1.0
            }
        case 8: // RRGGBBAA
            if scanner.scanHexInt32(&hdigit) {
                r = CGFloat((hdigit & 0xff000000) >> 24) / 255
                g = CGFloat((hdigit & 0x00ff0000) >> 16) / 255
                b = CGFloat((hdigit & 0x0000ff00) >> 08) / 255
                a = CGFloat((hdigit & 0x000000ff) >> 00) / 255
            }

        default:
            break
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
