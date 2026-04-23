//
//  MapViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//


import UIKit
import MapboxMaps

class MapViewController: UIViewController {
    private let mapService: MapServiceProtocol
    private let locationService: LocationServiceProtocol
    private var mapView: MapView!

    
    init(mapService: MapServiceProtocol, locationService: LocationServiceProtocol) {
        self.mapService = mapService
        self.locationService = locationService
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(mapService:locationService:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"
        
        setMapView()
    }
    
    private func setMapView() {
        let options = MapInitOptions(styleURI: mapService.styleURI)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth,
                                    .flexibleHeight]
        view.addSubview(mapView)
        mapView.mapboxMap.setCamera(to: mapService.initialCamera)
    }
}

