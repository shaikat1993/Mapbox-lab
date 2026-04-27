//
//  MarkerModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit

enum MarkerShape: String, CaseIterable {
    case pin    = "pin"
    case dot    = "dot"
    case circle = "circle"
    case star   = "star"

    var title: String { rawValue.uppercased() }

    var systemIcon: String {
        switch self {
        case .pin:    return "mappin"
        case .dot:    return "circle.fill"
        case .circle: return "circle"
        case .star:   return "star"
        }
    }
}

enum MarkerColor: String, CaseIterable {
    case white  = "#FFFFFF"
    case green  = "#4CD964"
    case pink   = "#FF6B81"
    case orange = "#FF9500"
    case purple = "#BF5AF2"
    case teal   = "#5AC8FA"

    var uiColor: UIColor { UIColor(hex: rawValue) }
}

struct MarkerConfig {
    var label: String
    var shape: MarkerShape
    var color: MarkerColor
    var customImageData: Data?

    static var `default`: MarkerConfig {
        MarkerConfig(label: "Secret Spot",
                     shape: .pin,
                     color: .white,
                     customImageData: nil)
    }
}

extension MarkerConfig {
    func save(to defaults: UserDefaults = .standard) {
        defaults.set(label,           forKey: UserDefaultsKeys.Marker.label)
        defaults.set(shape.rawValue,  forKey: UserDefaultsKeys.Marker.shape)
        defaults.set(color.rawValue,  forKey: UserDefaultsKeys.Marker.color)
        defaults.set(customImageData, forKey: UserDefaultsKeys.Marker.imageData)
    }

    static func load(from defaults: UserDefaults = .standard) -> MarkerConfig {
        let label = defaults.string(forKey: UserDefaultsKeys.Marker.label) ?? MarkerConfig.default.label
        let shape = MarkerShape(rawValue: defaults.string(forKey: UserDefaultsKeys.Marker.shape) ?? "") ?? .pin
        let color = MarkerColor(rawValue: defaults.string(forKey: UserDefaultsKeys.Marker.color) ?? "") ?? .white
        let data  = defaults.data(forKey: UserDefaultsKeys.Marker.imageData)
        return MarkerConfig(label: label, shape: shape, color: color, customImageData: data)
    }
}
