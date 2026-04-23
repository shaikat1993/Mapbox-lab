//
//  AnnotationService.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/22/26.
//

import MapboxMaps
import CoreLocation

final class AnnotationService: AnnotationServiceProtocol {
    private weak var mapView: MapView?
    private var manager: PointAnnotationManager?
    
    init(mapView: MapView) {
        self.mapView = mapView
        self.manager = mapView.annotations.makePointAnnotationManager()
    }
    func addMarker(at coordinate: CLLocationCoordinate2D,
                   title: String) {
        var annotation = PointAnnotation(coordinate: coordinate)
        annotation.textField = title
        manager?.annotations.append(annotation)
    }
    
    func removeAllMarkers() {
        manager?.annotations = []
    }
    
    func updateMarkers(_ coordinates: [CLLocationCoordinate2D]) {
        manager?.annotations = coordinates.map({
            PointAnnotation(coordinate: $0)
        })
    }
}
