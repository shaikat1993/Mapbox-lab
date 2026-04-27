//
//  Constants.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import Foundation

enum UserDefaultsKeys {
    enum Settings {
        static let selectedMapStyle = "selected_map_style"
        static let overlayPrefix    = "overlay_"
    }

    enum Marker {
        static let label     = "marker_label"
        static let shape     = "marker_shape"
        static let color     = "marker_color"
        static let imageData = "marker_image_data"
    }
}
