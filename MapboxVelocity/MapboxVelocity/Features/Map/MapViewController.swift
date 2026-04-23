//
//  MapViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//

import UIKit
import MapboxMaps
import Combine

class MapViewController: UIViewController {
    private let mapService: MapServiceProtocol
    private let locationService: LocationServiceProtocol
    private var mapView: MapView!
    private var cancellables = Set<AnyCancellable>()

    init(mapService: MapServiceProtocol, locationService: LocationServiceProtocol) {
        self.mapService = mapService
        self.locationService = locationService
        super.init(nibName: nil, bundle: nil)
        initMapView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(mapService:locationService:)") }

    private func initMapView() {
        let options = MapInitOptions(styleURI: mapService.styleURI)
        mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.setCamera(to: mapService.initialCamera)
        mapView.mapboxMap.onStyleLoaded.observe { [weak self] _ in
            self?.addOverlayLayers()
        }.store(in: &cancellables)
        bindChanges()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"
        view.addSubview(mapView)
    }

    private func bindChanges() {
        mapService.styleDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                self?.mapView.mapboxMap.loadStyle(style.styleURI)
            }
            .store(in: &cancellables)

        mapService.overlayDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                self?.applyOverlay(id: change.id, isEnabled: change.isEnabled)
            }
            .store(in: &cancellables)
    }

    private func addOverlayLayers() {
        guard let map = mapView?.mapboxMap else {
            print("[MapVC] ❌ addOverlayLayers: mapboxMap is nil")
            return
        }
        let availableSources = map.allSourceIdentifiers.map(\.id)
        let existingLayers = map.allLayerIdentifiers.map(\.id)

        guard availableSources.contains("composite") else { return }
        if !existingLayers.contains("overlay-buildings") { add3DBuildings(map: map) }
        addTrafficLayer(map: map)
        applyPersistedOverlays(map: map)
    }

    private func applyPersistedOverlays(map: MapboxMap) {
        let defaults = UserDefaults.standard
        for id in ["buildings", "traffic"] {
            let key = UserDefaultsKeys.Settings.overlayPrefix + id
            let stored = defaults.object(forKey: key)
            let isEnabled = stored != nil ? defaults.bool(forKey: key) : false
            applyOverlay(id: id, isEnabled: isEnabled, map: map)
        }
    }

    private func add3DBuildings(map: MapboxMap) {
        var layer = FillExtrusionLayer(id: "overlay-buildings", source: "composite")
        layer.sourceLayer = "building"
        layer.filter = Exp(.eq) { Exp(.get) { "extrude" }; "true" }
        layer.fillExtrusionHeight = .expression(Exp(.get) { "height" })
        layer.fillExtrusionBase = .expression(Exp(.get) { "min_height" })
        layer.fillExtrusionColor = .constant(StyleColor(UIColor(hex: "#adc6ff")))
        layer.fillExtrusionOpacity = .constant(0.8)
        layer.visibility = .constant(.visible)
        try? map.addLayer(layer)
    }

    private func addTrafficLayer(map: MapboxMap) {
        var source = VectorSource(id: "traffic-source")
        source.url = "mapbox://mapbox.mapbox-traffic-v1"

        var layer = LineLayer(id: "overlay-traffic", source: "traffic-source")
        layer.sourceLayer = "traffic"
        layer.lineColor = .expression(
            Exp(.match) {
                Exp(.get) { "congestion" }
                "low";      "#53e16f"
                "moderate"; "#f4a261"
                "heavy";    "#e63946"
                "severe";   "#9b2226"
                "#53e16f"
            }
        )
        layer.lineWidth = .constant(2.5)
        layer.visibility = .constant(.visible)

        try? map.addSource(source)
        try? map.addLayer(layer)
    }

    private func applyOverlay(id: String, isEnabled: Bool) {
        guard let map = mapView?.mapboxMap else { return }
        applyOverlay(id: id, isEnabled: isEnabled, map: map)
    }

    private func applyOverlay(id: String, isEnabled: Bool, map: MapboxMap) {
        let value = isEnabled ? "visible" : "none"
        switch id {
        case "buildings":
            try? map.setLayerProperty(for: "overlay-buildings", property: "visibility", value: value)
        case "traffic":
            try? map.setLayerProperty(for: "overlay-traffic", property: "visibility", value: value)
        default:
            break
        }
    }
}
