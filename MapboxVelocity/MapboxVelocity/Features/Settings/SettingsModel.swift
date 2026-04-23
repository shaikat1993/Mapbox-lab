//
//  SettingsModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit
import MapboxMaps

enum MapStyle: CaseIterable{
    case standard
    case dark
    case satellite
    case heatmap
    case wolt
    
    var title: String {
        switch self {
        case .standard:     return "Standard"
        case .dark:         return "Dark"
        case .satellite:    return "Satellite"
        case .heatmap:      return "HeatMap"
        case .wolt:         return "Wolt"
        }
    }
    
    var subtitle: String {
        switch self {
        case .standard:  return "High-legibility"
        case .dark:      return "Kinetic Core"
        case .satellite: return "Orbital imagery"
        case .heatmap:   return "Density view"
        case .wolt:      return "Cream base · pastel blocks · courier pins"
        }
    }
    
    var previewImage: String {
           switch self {
           case .standard:  return "map"
           case .dark:      return "moon.fill"
           case .satellite: return "globe"
           case .heatmap:   return "flame.fill"
           case .wolt:      return "fork.knife"
           }
       }
    
    var isInspired: Bool { self == .wolt }
    var isFullWidth: Bool { self == .wolt }

    var styleURI: StyleURI {
        switch self {
        case .standard:  return .standard
        case .dark:      return .dark
        case .satellite: return .satellite
        case .heatmap:   return .outdoors
        case .wolt:      return StyleURI(rawValue: "mapbox://styles/sadidur25/cmobqf8oo001k01sh5wxo0u08")!
        }
    }
    
    var accentColor: UIColor {
        switch self {
        case .standard:  return UIColor(hex: "#adb5bd")
        case .dark:      return UIColor(hex: "#adc6ff")
        case .satellite: return UIColor(hex: "#53e16f")
        case .heatmap:   return UIColor(hex: "#f4a261")
        case .wolt:      return UIColor(hex: "#009de0")
        }
    }
    
    var selectedCardBackground: UIColor {
        switch self {
        case .standard:  return UIColor(hex: "#e8e8e8").withAlphaComponent(0.12)
        case .dark:      return UIColor(hex: "#adc6ff").withAlphaComponent(0.08)
        case .satellite: return UIColor(hex: "#53e16f").withAlphaComponent(0.08)
        case .heatmap:   return UIColor(hex: "#f4a261").withAlphaComponent(0.10)
        case .wolt:      return UIColor(hex: "#f5efe6").withAlphaComponent(0.10)
        }
    }
}

struct TechnicalOverlay{
    var id : String
    var title: String
    var subTitle: String
    var icon: String
    var isEnabled: Bool
}

extension TechnicalOverlay {
    static var defaults: [TechnicalOverlay] {
        [
        TechnicalOverlay(id: "buildings",
                         title: "3D Buildings",
                         subTitle: "Render volumetric structures",
                         icon: "building.2",
                         isEnabled: false),
        TechnicalOverlay(id: "traffic",
                         title: "Real-time Traffic",
                         subTitle: "Live congestion telemetry",
                         icon: "car.2",
                         isEnabled: false)
        ]
    }
}
