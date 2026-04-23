//
//  AnnotationServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/21/26.
//

import MapboxMaps
import CoreLocation

protocol AnnotationServiceProtocol : AnyObject {
    func addMarker(at coordinate: CLLocationCoordinate2D,
                   title: String)
    func removeAllMarkers()
    func updateMarkers(_ coordinates: [CLLocationCoordinate2D])
}
