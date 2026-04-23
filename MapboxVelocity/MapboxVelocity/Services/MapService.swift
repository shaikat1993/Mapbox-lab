//
//  MapboxVelocity
//
//  Created by Shaikat on 4/17/26.
//

import MapboxMaps
import CoreLocation
import Combine

final class MapService: MapServiceProtocol {

    private(set) var selectedStyle: MapStyle = .dark
    var styleURI: StyleURI { selectedStyle.styleURI }

    let styleDidChange = PassthroughSubject<MapStyle, Never>()
    let overlayDidChange = PassthroughSubject<(id: String, isEnabled: Bool), Never>()

    var initialCamera: CameraOptions {
        CameraOptions(
            center: CLLocationCoordinate2D(latitude: 61.4978, longitude: 23.7610),
            zoom: 12.0,
            bearing: 0,
            pitch: 0
        )
    }

    func updateStyle(_ style: MapStyle) {
        selectedStyle = style
        styleDidChange.send(style)
    }

    func updateOverlay(id: String, isEnabled: Bool) {
        overlayDidChange.send((id: id, isEnabled: isEnabled))
    }
}
