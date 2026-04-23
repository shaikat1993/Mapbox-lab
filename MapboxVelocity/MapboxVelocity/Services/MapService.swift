//
//  MapboxVelocity
//
//  Created by Shaikat on 4/17/26.
//

import MapboxMaps
import CoreLocation

final class MapService: MapServiceProtocol {
    var styleURI: MapboxMaps.StyleURI { .dark }
    var initialCamera: MapboxCoreMaps.CameraOptions{
        CameraOptions(center: CLLocationCoordinate2D(latitude: 61.4978,
                                                     longitude: 23.7610),
                      zoom: 12.0,
                      bearing: 0,
                      pitch: 0
        )
    }
}
