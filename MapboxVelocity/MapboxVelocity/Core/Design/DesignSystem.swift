//
//  DesignSystem.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/3/26.
//

import UIKit
import MapboxMaps

// MARK: - Design System Protocol (Interface Segregation Principle)

// Consumers depend on this protocol, not the concrete enum.

protocol DesignSystemProviding {
    var primaryColor: UIColor { get }
    var secondaryColor: UIColor { get }
    var surfaceColor: UIColor { get }
    var mapStyleURI: StyleURI { get }
}

// MARK: - Concrete implementation from UI/UX Design
struct VelocityDesignSystem: DesignSystemProviding {
    // Backgrounds
    let backgroundColor  = UIColor(hex: "#121212")
    let surfaceColor     = UIColor(hex: "#1C1C1E")
    let surface2Color    = UIColor(hex: "#2C2C2E")
    
    // Brand
    let primaryColor     = UIColor(hex: "#007AFF")  // Main CTA
    let secondaryColor   = UIColor(hex: "#34C759")  // Success/confirm
    let tertiaryColor    = UIColor(hex: "#FF9500")  // Warning/zone 3
    
    // Text
    let textPrimary      = UIColor.white
    let textSecondary    = UIColor(hex: "#8E8E93")
    let textTertiary     = UIColor(hex: "#636366")
    
    // Map style matching dark theme
    let mapStyleURI: StyleURI = .dark
    
    // Spacing scale (4pt base grid)
    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }
    
    // Corner radius tokens
    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 24
    }
    
    // Typography
    enum Typography {
        static let headline = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title    = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body     = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption  = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let button   = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
}
