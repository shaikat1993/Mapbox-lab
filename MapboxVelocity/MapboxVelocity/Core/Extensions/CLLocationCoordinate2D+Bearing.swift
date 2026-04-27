//
//  CLLocationCoordinate2D+Bearing.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/27/26.
//

import CoreLocation

extension CLLocationCoordinate2D {

    /// Bearing in degrees (0–360) from this coordinate toward `destination`.
    /// 0° = North, 90° = East, 180° = South, 270° = West.
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude  * .pi / 180
        let lat2 = destination.latitude  * .pi / 180
        let dLon = (destination.longitude - longitude) * .pi / 180

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}
