//
//  Extensions.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/3/26.
//
import UIKit

// MARK: - UIColor Hex Extension (Core/Extensions/UIColor+Hex.swift)
extension UIColor {
    convenience init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard sanitized.count == 6,
              Scanner(string: sanitized).scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >>  8) / 255,
            blue:  CGFloat( rgb & 0x0000FF       ) / 255,
            alpha: 1
        )
    }
}

@IBDesignable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}
