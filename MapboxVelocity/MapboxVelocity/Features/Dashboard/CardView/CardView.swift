//
//  CardView.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//

import UIKit

class CardView: UIView {

    // -----------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateCorners()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateCorners()
    }

    // -----------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------

    var roundedCornerRadius: CGFloat = 0.0 {
        didSet { updateCorners() }
    }

    var roundedCorners: UIRectCorner = [] {
        didSet { updateCorners() }
    }

    override var bounds: CGRect {
        didSet { updateCorners() }
    }

    // -----------------------------------------------------
    // MARK: - Private Utils
    // -----------------------------------------------------

    func updateCorners() {
        if roundedCornerRadius > 0 && roundedCorners != [] {
            var maskLayer: CAShapeLayer
            if let _layer = layer.mask as? CAShapeLayer {
                maskLayer = _layer
            } else {
                maskLayer = CAShapeLayer()
                maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
                maskLayer.fillColor = UIColor.black.cgColor
                layer.mask = maskLayer
            }

            let path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: roundedCorners,
                                    cornerRadii: CGSize(width: roundedCornerRadius,
                                                        height: roundedCornerRadius))
            maskLayer.path = path.cgPath
            maskLayer.frame = bounds

            layer.masksToBounds = true
        } else {
            layer.mask = nil
            layer.masksToBounds = false
        }
    }
}

class RoundedShadowView: UIView {
    
    var shadowRadius: CGFloat = 4.0 {
        didSet {
            drawShadow()
        }
    }
    var shadowColor: UIColor =  UIColor(red:0, green:0, blue:0, alpha:0.08) {
        didSet {
            drawShadow()
        }
    }
    var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            drawShadow()
        }
    }
    var shadowOpacity: Float = 1.0 {
        didSet {
            drawShadow()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        drawShadow()
    }
    
    private func drawShadow() {
        layer.cornerRadius = shadowRadius
        backgroundColor = .white
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}
