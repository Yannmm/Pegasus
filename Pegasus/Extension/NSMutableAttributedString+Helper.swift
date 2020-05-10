//
//  NSMutableAttributedString+Utility.swift
//  aligntech-stpe
//
//  Created by Rayman Yan on 2019/8/17.
//  Copyright © 2019 Align Technology Inc. All rights reserved.
//

import UIKit

public extension String {
    var attributed: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
}

public extension NSMutableAttributedString {
    @discardableResult
    func font(_ font: UIFont, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.font, value: font, range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func color(_ color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func image(image: UIImage, origin: CGPoint? = nil, size: CGSize? = nil) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        if let o = origin {
            attachment.bounds.origin = CGPoint(x: o.x, y: o.y)
        } else {
            attachment.bounds.origin = CGPoint.zero
        }
        if let s = size {
            attachment.bounds = CGRect(x: attachment.bounds.origin.x, y: attachment.bounds.origin.y, width: s.width, height: s.height)
        } else {
            attachment.bounds = CGRect(x: attachment.bounds.origin.x, y: attachment.bounds.origin.y, width: image.size.width, height: image.size.height)
        }

        attachment.image = image
        let imas = NSAttributedString(attachment: attachment)
        append(imas)
        return self
    }

    @discardableResult
    func underline(color: UIColor, weight: Double = 1, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.underlineStyle, value: weight, range: range ?? NSRange(location: 0, length: string.count))
        addAttribute(NSAttributedString.Key.underlineColor, value: color, range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    func baselineOffset(offset: NSNumber, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttribute(NSAttributedString.Key.baselineOffset, value: offset, range: range ?? NSRange(location: 0, length: string.count))
        return self
    }

    @discardableResult
    static func + (left: NSMutableAttributedString, right: NSMutableAttributedString) -> NSMutableAttributedString {
        left.append(right)
        return left
    }

    static func += (left: NSMutableAttributedString, right: NSMutableAttributedString) {
        left + right
    }
}

