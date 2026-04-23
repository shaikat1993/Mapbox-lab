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
        var sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >>  8) / 255,
            blue:  CGFloat( rgb & 0x0000FF       ) / 255,
            alpha: 1
        )
    }
}
