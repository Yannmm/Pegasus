//
//  LEGO.swift
//  Lego
//
//  Created by Rayman Yan on 2019/10/10.
//  Copyright © 2019 Align Technology Inc. All rights reserved.
//

import UIKit

// MARK: Lego
public extension UIView {
    var lego: Lego { return Lego(self) }
}

public struct Lego {
    fileprivate let target: Constrainable
    fileprivate init(_ target: UIView) {
        self.target = target
    }
}

extension Lego {
    func build(_ closure: (Builder) -> Void) {
        let b = Builder(target: target)
        closure(b)
        let constraints = b.descriptions.flatMap { $0.create() }
        constraints.forEach { $0.isActive = true }
    }

    func rebuild(_ closure: (Builder) -> Void) {
        // FIXME: Should UIlayoutGuide implement removeAllConstraints?
        (target as? UIView)?.removeAllConstraints()
        build(closure)
    }
}

extension Lego {
    var leading: Wedge { return .leading(target) }
    var trailing: Wedge { return .trailing(target) }
    var left: Wedge { return .left(target) }
    var right: Wedge { return .right(target) }
    var top: Wedge { return .top(target) }
    var bottom: Wedge { return .bottom(target) }
    var centerX: Wedge { return .centerX(target) }
    var centerY: Wedge { return .centerY(target) }
    var height: Wedge { return .height(target) }
    var width: Wedge { return .width(target) }
}

// MARK: Public - Builder
extension Builder {
    var leading: Builder {
      prepare(.leading(target))
      return self
    }

    var trailing: Builder {
      prepare(.trailing(target))
      return self
    }

    var left: Builder {
      prepare(.left(target))
      return self
    }

    var right: Builder {
      prepare(.right(target))
      return self
    }

    var top: Builder {
      prepare(.top(target))
      return self
    }

    var bottom: Builder {
      prepare(.bottom(target))
      return self
    }

    var centerX: Builder {
      prepare(.centerX(target))
      return self
    }

    var centerY: Builder {
      prepare(.centerY(target))
      return self
    }

    var center: Builder {
      prepare(.centerX(target))
      prepare(.centerY(target))
      return self
    }

    var width: Builder {
      prepare(.width(target))
      return self
    }

    var height: Builder {
      prepare(.height(target))
      return self
    }

    var size: Builder {
      prepare(.width(target))
      prepare(.height(target))
      return self
    }

    var edges: Builder {
      prepare(.leading(target))
      prepare(.trailing(target))
      prepare(.top(target))
      prepare(.bottom(target))
      return self
    }
}

// MARK: Layout Properties
extension Builder {
    @discardableResult
    func offset(_ offset: CGFloat) -> Builder {
        current.offset = offset
        return self
    }

    @discardableResult
    func insets(_ insets: UIEdgeInsets) -> Builder {
        current.insets = insets.autolayoutSemantified
        return self
    }

    @discardableResult
    func constant(_ constant: CGFloat) -> Builder {
        current.constant = constant
        return self
    }

    @discardableResult
    func multiplier(_ multiplier: CGFloat) -> Builder {
        current.multiplier = multiplier
        return self
    }

    @discardableResult
    func priority(_ priority: Float) -> Builder {
        current.priorityAsFloat = priority
        return self
    }

    @discardableResult
    func priority(_ priority: UILayoutPriority) -> Builder {
        current.priority = priority
        return self
    }
}

// MARK: Layout Relation - Equal
extension Builder {
    @discardableResult
    func equalToSuperview() -> Builder {
        current.peer = target.superview!
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func equalTo(_ wedge: Wedge) -> Builder {
        current.peer = wedge.view
        current.pattributes += wedge.attributes
        return self
    }

    @discardableResult
    func equalTo(_ viewlike: Constrainable) -> Builder {
        current.peer = viewlike
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func equalTo(_ size: CGSize) -> Builder {
        current.peer = nil
        current.pattributes = [.notAnAttribute]
        current.size = size
        return self
    }

    @discardableResult
    func equalTo(_ dimension: CGFloat) -> Builder {
        current.peer = nil
        current.pattributes = [.notAnAttribute]
        current.dimension = dimension
        return self
    }
}

// MARK: Layout Relation - Greater than or equal to
extension Builder {
    @discardableResult
    func greaterThanOrEqualTo(_ viewlike: Constrainable) -> Builder {
        current.relation = .greaterThanOrEqual
        current.peer = viewlike
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func greaterThanOrEqualTo(_ dimension: CGFloat) -> Builder {
        current.peer = nil
        current.pattributes = [.notAnAttribute]
        current.dimension = dimension
        current.relation = .greaterThanOrEqual
        return self
    }

    @discardableResult
    func greaterThanOrEqualToSuperview() -> Builder {
        current.relation = .greaterThanOrEqual
        current.peer = target.superview!
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func greaterThanOrEqualTo(_ wedge: Wedge) -> Builder {
        current.relation = .greaterThanOrEqual
        current.peer = wedge.view
        current.pattributes += wedge.attributes
        return self
    }
}

// MARK: Layout Relation - Less than or equal to
extension Builder {
    @discardableResult
    func lessThanOrEqualTo(_ viewlike: Constrainable) -> Builder {
        current.relation = .lessThanOrEqual
        current.peer = viewlike
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func lessThanOrEqualTo(_ dimension: CGFloat) -> Builder {
        current.peer = nil
        current.pattributes = [.notAnAttribute]
        current.dimension = dimension
        current.relation = .lessThanOrEqual
        return self
    }

    @discardableResult
    func lessThanOrEqualToSuperview() -> Builder {
        current.relation = .lessThanOrEqual
        current.peer = target.superview!
        current.pattributes = current.mattributes
        return self
    }

    @discardableResult
    func lessThanOrEqualTo(_ wedge: Wedge) -> Builder {
        current.relation = .lessThanOrEqual
        current.peer = wedge.view
        current.pattributes += wedge.attributes
        return self
    }
}

// MARK: Private - Builder
class Builder {
    private let target: Constrainable
    private var current: Description!

    fileprivate var descriptions = [Description]()
    fileprivate init(target: Constrainable) {
        self.target = target
        self.target.disableAutoresizingMaskTranslation()
    }

    // FIXME: b.centerY.height.equalToSuperview() will error. Because location and size can't be within the same sentence. Enable them to be together.
    private func prepare(_ wedge: Wedge) {
        if current == nil {
            current = Description(target: target)
            descriptions.append(current)
        }

        switch current.purpose {
        case .pending:
            current.mattributes += wedge.attributes

        case .locating:
            switch wedge.usage {
            case .pinning:
                if current.peer == nil {
                    current.mattributes += wedge.attributes
                } else {
                    current = Description(target: target)
                    descriptions.append(current)
                    current.mattributes += wedge.attributes
                }

            case .holding:
                current = Description(target: target)
                descriptions.append(current)
                current.mattributes += wedge.attributes
            }

        case .sizing:
            switch wedge.usage {
            case .holding:
                if let a = current.pattributes.first, a == .notAnAttribute || current.peer != nil {
                    current = Description(target: target)
                    descriptions.append(current)
                    current.mattributes += wedge.attributes
                } else {
                    current.mattributes += wedge.attributes
                }

            case .pinning:
                current = Description(target: target)
                descriptions.append(current)
                current.mattributes += wedge.attributes
            }
        }
    }
}

// MARK: Description - Describe a layout
private class Description {
    init(target: Constrainable) {
        self.target = target
    }

    let target: Constrainable
    var peer: Constrainable?
    var mattributes: [NSLayoutConstraint.Attribute] = []
    var pattributes: [NSLayoutConstraint.Attribute] = []
    var relation: NSLayoutConstraint.Relation = .equal
    var multiplier: CGFloat = 1.0
    var constant: CGFloat = 0.0

    var priority: UILayoutPriority = .required
    var priorityAsFloat: Float {
        get {
            return priority.rawValue
        }
        set {
            priority = UILayoutPriority(newValue)
        }
    }

    var offset: CGFloat {
        get {
            fatalError(LEGO.warinig() + "Never try to read from offset.")
        }
        set {
            assert(purpose == .locating, LEGO.warinig() + "You can't set offset for size attribute!!!")
            insets = UIEdgeInsets(offset: newValue, attributes: mattributes)
        }
    }

    var size: CGSize = .zero {
        willSet {
            assert(purpose == .sizing, LEGO.warinig() + "Never try to set size for location attribute!!!")
        }
    }

    var dimension: CGFloat {
        get {
            fatalError(LEGO.warinig() +  "Never try to read from dimension.")
        }
        set {
            size = CGSize(dimension: newValue, attributes: mattributes)
        }
    }

//    private var _insets: UIEdgeInsets = .zero
    var insets: UIEdgeInsets = .zero {
        willSet {
            assert(purpose == .locating, LEGO.warinig() + "Never try to set insets for size attribute!!!")
        }
    }
}

extension Description {
    func create() -> [NSLayoutConstraint] {
        if purpose != .sizing {
            assert(target.attached, LEGO.warinig() +  "Add constraints after adding view to superview!!!")
        }
        guard mattributes.count > 0 && pattributes.count > 0 else { fatalError(LEGO.warinig() +  "Attributes won't pair!!!") }
        if pattributes.count == 1 { // many -> one
            let pa = pattributes.first!
            let result = mattributes.map { ma -> NSLayoutConstraint in
                let constraint = NSLayoutConstraint(item: target, attribute: ma, relatedBy: relation, toItem: peer, attribute: pa, multiplier: multiplier, constant: calculateConstant(ma))
                constraint.priority = priority
                constraint.identifier = LEGO.identifier
                return constraint
            }
            return result
        } else { // many -> many
            var result = [NSLayoutConstraint]()
            for (i, ma) in mattributes.enumerated() {
                let pa = pattributes[i]
                let constraint = NSLayoutConstraint(item: target, attribute: ma, relatedBy: relation, toItem: peer, attribute: pa, multiplier: multiplier, constant: calculateConstant(ma))
                constraint.priority = priority
                constraint.identifier = LEGO.identifier
                result.append(constraint)
            }
            return result
        }
    }

    func calculateConstant(_ a: NSLayoutConstraint.Attribute) -> CGFloat {
        switch purpose {
        case .sizing:
            return size.value(for: a) + constant

        case .locating:
            return insets.value(for: a) + constant

        default:
            assert(false, LEGO.warinig() + "You can't use this way")
            return 0.0
        }
    }
}

extension Description {
    enum Purpose {
        case pending
        case sizing
        case locating
    }

    var purpose: Purpose {
        guard let myFirst = mattributes.first else { return .pending }
        switch myFirst {
        case .width, .height: return .sizing
        case .notAnAttribute: fatalError(LEGO.warinig() + "My attributes can never be .notAnAttribute!!!")
        default: return .locating
        }
    }
}

// MARK: Wedge
enum Wedge {
    // x, y
    case leading(Constrainable)
    case trailing(Constrainable)
    case left(Constrainable)
    case right(Constrainable)
    case bottom(Constrainable)
    case top(Constrainable)
    case centerX(Constrainable)
    case centerY(Constrainable)
    case center(Constrainable)
    // w, h
    case width(Constrainable)
    case height(Constrainable)

    var view: Constrainable {
        switch self {
        case .leading(let v): return v
        case .trailing(let v): return v
        case .left(let v): return v
        case .right(let v): return v
        case .bottom(let v): return v
        case .top(let v): return v
        case .centerX(let v): return v
        case .centerY(let v): return v
        case .center(let v): return v
        case .width(let v): return v
        case .height(let v): return v
        }
    }

    var attributes: [NSLayoutConstraint.Attribute] {
        switch self {
        case .leading: return [.leading]
        case .trailing: return [.trailing]
        case .left: return [.left]
        case .right: return [.right]
        case .bottom: return [.bottom]
        case .top: return [.top]
        case .centerX: return [.centerX]
        case .centerY: return [.centerY]
        case .center: return [.centerX, .centerY]
        case .width: return [.width]
        case .height: return [.height]
        }
    }

    fileprivate enum Usage {
        case pinning // pin to a position
        case holding // hold up a size
    }

    fileprivate var usage: Usage {
        switch self {
        case .leading, .trailing, .bottom, .top, .centerX, .centerY, .center, .left, .right:
            return .pinning

        case .width, .height:
            return .holding
        }
    }
}

// MARK: Constrainable
protocol Constrainable {
    var attached: Bool { get }
    var superview: UIView? { get }
    func disableAutoresizingMaskTranslation()
}

extension UILayoutGuide: Constrainable {
    var attached: Bool {
        return owningView != nil
    }

    var superview: UIView? {
        return owningView?.superview
    }

    func disableAutoresizingMaskTranslation() {}
}

extension UIView: Constrainable {
    var attached: Bool {
        return superview != nil
    }

    func disableAutoresizingMaskTranslation() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: Extension
fileprivate extension UIEdgeInsets {
    func value(for attribute: NSLayoutConstraint.Attribute) -> CGFloat {
        switch attribute {
        case .top: return top
        case .bottom: return bottom
        case .leading: return left
        case .trailing: return right
        case .centerX: return left
        case .centerY: return top
        default: return 0.0
        }
    }

    init(offset: CGFloat, attributes: [NSLayoutConstraint.Attribute]) {
        var l: CGFloat = 0.0
        var r: CGFloat = 0.0
        var t: CGFloat = 0.0
        var b: CGFloat = 0.0
        for a in attributes {
            switch a {
            case .leading: l = offset
            case .trailing: r = offset
            case .top: t = offset
            case .bottom: b = offset
            case .centerX: l = offset
            case .centerY: t = offset
            default: print(LEGO.warinig() + "Unexpected attribute: \(a)")
            }
        }
        self = UIEdgeInsets(top: t, left: l, bottom: b, right: r)
    }

    var autolayoutSemantified: UIEdgeInsets {
        var copy = self
        copy.right = -copy.right
        copy.bottom = -copy.bottom
        return copy
    }
}

fileprivate extension CGSize {
    func value(for attribute: NSLayoutConstraint.Attribute) -> CGFloat {
        switch attribute {
        case .width: return width
        case .height: return height
        default: return 0.0
        }
    }

    init(dimension: CGFloat, attributes: [NSLayoutConstraint.Attribute]) {
        var w: CGFloat = 0.0
        var h: CGFloat = 0.0
        for a in attributes {
            switch a {
            case .width: w = dimension
            case .height: h = dimension
            default: print(LEGO.warinig() + "Unexpected attribute: \(a)")
            }
        }
        self = CGSize(width: w, height: h)
    }
}

fileprivate extension UIView {
    func removeAllConstraints() {
        var next: UIView? = self
        while let n = next {
            let removed = n.constraints.filter {
                $0.identifier == LEGO.identifier &&
                    ($0.firstItem as? UIView === self || $0.secondItem as? UIView === self)
            }
            NSLayoutConstraint.deactivate(removed)
            next = next?.superview
        }
    }
}

// MARK: Constants
private enum LEGO {
    static func warinig(_ l: Int = #line) -> String { return "(🧱 @\(l)): " }
    static let identifier = "com.lego.buidyourdream"
}
