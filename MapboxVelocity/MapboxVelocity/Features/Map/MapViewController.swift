//
//  MapViewController.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/9/26.
//

import UIKit
import MapboxMaps
import Combine
import SwiftUI

class MapViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var mapView: MapView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pickupTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var suggestionsTableView: UITableView! {
        didSet {
            suggestionsTableView.delegate = self
            suggestionsTableView.dataSource = self
            suggestionsTableView.backgroundColor = UIColor(hex: "#1a1f2e").withAlphaComponent(0.20)
            suggestionsTableView.separatorColor = UIColor.white.withAlphaComponent(0.08)
            suggestionsTableView.overrideUserInterfaceStyle = .dark
            suggestionsTableView.isHidden = true
        }
    }

    // MARK: - Dependencies

    private var mapService: MapServiceProtocol!
    private var locationService: LocationServiceProtocol!
    private var tripViewModel: TripViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Trip / Animation

    private let rideAnimator = RideAnimator()
    private var annotationManager: PointAnnotationManager?
    private var vehicleAnnotationView: UIImageView?
    private enum SearchField { case pickup, destination }
    private var activeSearchField: SearchField = .pickup
    private var markerConfig: MarkerConfig = .load()
    private var userIsInteractingWithMap = false

    // Each field keeps its own result cache so switching fields never corrupts the other
    private var pickupResults: [GeocodingResult] = []
    private var destinationResults: [GeocodingResult] = []
    private var searchResults: [GeocodingResult] {
        activeSearchField == .pickup ? pickupResults : destinationResults
    }

    private static let routeSourceID    = "trip-route-source"
    private static let routeLayerID     = "trip-route-layer"
    private static let pickupPinID      = "pickup-pin"
    private static let destinationPinID = "destination-pin"

    // MARK: - Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(mapService: MapServiceProtocol,
                   locationService: LocationServiceProtocol,
                   tripViewModel: TripViewModel) {
        self.mapService = mapService
        self.locationService = locationService
        self.tripViewModel = tripViewModel
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        markerConfig = .load()
        // Redraw pickup pin with latest marker config in case user changed it in Markers tab
        if let pickup = tripViewModel.trip.pickup {
            placePin(coordinate: pickup.coordinate, id: Self.pickupPinID, image: pickupImage())
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        pickupTextField.delegate = self
        destinationTextField.delegate = self
        annotationManager = mapView.annotations.makePointAnnotationManager()
        bindViewModel()
        setupRideAnimator()
        setupMapTap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationService.requestPermission()
        locationService.startUpdating()

        // If we already have a fix, center immediately; otherwise wait for the first one
        if let location = locationService.lastKnownLocation {
            mapView.camera.ease(to: CameraOptions(center: location.coordinate, zoom: 14), duration: 0.5)
        } else {
            locationService.currentLocation
                .first()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] location in
                    self?.mapView.camera.ease(to: CameraOptions(center: location.coordinate, zoom: 14), duration: 0.8)
                }
                .store(in: &cancellables)
        }
    }

    // MARK: - Setup

    private func setupMap() {
        mapView.mapboxMap.setCamera(to: mapService.initialCamera)
        mapView.mapboxMap.onStyleLoaded.observe { [weak self] _ in
            self?.addOverlayLayers()
        }.store(in: &cancellables)
        mapView.ornaments.options.compass.visibility = .adaptive
        mapView.ornaments.options.compass.position = .bottomRight
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.location.options.puckType = .puck2D()
        setupLocationButton()

        mapService.styleDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in self?.mapView.mapboxMap.loadStyle(style.styleURI) }
            .store(in: &cancellables)

        mapService.overlayDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in self?.applyOverlay(id: change.id,
                                                             isEnabled: change.isEnabled) }
            .store(in: &cancellables)

        mapView.gestures.delegate = self
    }

    private func setupLocationButton() {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "location.fill", withConfiguration: symbolConfig), for: .normal)
        button.tintColor = UIColor(hex: "#007AFF")
        button.backgroundColor = UIColor(hex: "#1a1f2e")
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)

        mapView.addSubview(button)

        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 49
        let buttonBottom = tabBarHeight + 36  // 36pt above tab bar

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -buttonBottom)
        ])

        // compass: same bottom edge reference + button height + 12pt gap
        let compassY = buttonBottom + 44 + 12
        mapView.ornaments.options.compass.margins = CGPoint(x: 16, y: compassY)
    }

    @objc private func centerOnUserLocation() {
        guard let location = locationService.lastKnownLocation else { return }
        mapView.camera.ease(
            to: CameraOptions(center: location.coordinate, zoom: 15),
            duration: 0.5
        )
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
        tripViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .routeReady:
                    self.drawRoute()
                    UIView.animate(withDuration: 0.3) { self.topView.alpha = 0 }
                    self.showBottomSheet()
                case .riding:
                    hideKeyboard()
                    self.dismiss(animated: true)
                    UIView.animate(withDuration: 0.3) { self.topView.alpha = 0 }
                    self.rideAnimator.start(along: self.tripViewModel.routeCoordinates)
                case .rideEnded:
                    self.rideAnimator.stop()
                    self.clearTrip()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        tripViewModel.$trip
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trip in
                guard let self else { return }
                if let pickup = trip.pickup {
                    self.placePin(coordinate: pickup.coordinate, id: Self.pickupPinID, image: self.pickupImage())
                }
                if let destination = trip.destination {
                    self.placePin(coordinate: destination.coordinate, id: Self.destinationPinID, color: UIColor(hex: "#FF3B30"))
                }
            }
            .store(in: &cancellables)

        tripViewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self else { return }
                // Write into the cache for whichever field triggered this search
                if self.activeSearchField == .pickup {
                    self.pickupResults = results
                } else {
                    self.destinationResults = results
                }
                self.suggestionsTableView.isHidden = results.isEmpty
                self.suggestionsTableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - RideAnimator

    private func setupRideAnimator() {
        rideAnimator.onCoordinateUpdate = { [weak self] coordinate, bearing in
            guard let self else { return }
            self.moveVehicleViewAnnotation(to: coordinate, bearing: bearing)
            guard !self.userIsInteractingWithMap else { return }
            self.mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: 15),
                                     duration: self.rideAnimator.stepInterval)
        }
        rideAnimator.onCompletion = { [weak self] in
            self?.removeVehicleViewAnnotation()
            self?.tripViewModel.endRide()
        }
    }

    private func addVehicleViewAnnotation(at coordinate: CLLocationCoordinate2D, bearing: Double) {
        let size: CGFloat = 40
        let imageView = UIImageView(image: vehicleImage())
        imageView.contentMode = .scaleAspectFit
        imageView.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        imageView.transform = rotationTransform(for: bearing)

        let point = mapView.mapboxMap.point(for: coordinate)
        imageView.center = point

        mapView.addSubview(imageView)
        vehicleAnnotationView = imageView
    }

    private func moveVehicleViewAnnotation(to coordinate: CLLocationCoordinate2D, bearing: Double) {
        guard let view = vehicleAnnotationView else {
            addVehicleViewAnnotation(at: coordinate, bearing: bearing)
            return
        }

        let point = mapView.mapboxMap.point(for: coordinate)

        UIView.animate(withDuration: rideAnimator.stepInterval,
                       delay: 0,
                       options: [.curveLinear, .beginFromCurrentState]) {
            view.transform = self.rotationTransform(for: bearing)
            view.center = point
        }
    }

    private func removeVehicleViewAnnotation() {
        vehicleAnnotationView?.removeFromSuperview()
        vehicleAnnotationView = nil
    }

    private func rotationTransform(for bearing: Double) -> CGAffineTransform {
        let angle = (bearing - tripViewModel.trip.vehicle.bearingOffset) * .pi / 180
        return CGAffineTransform(rotationAngle: CGFloat(angle))
    }

    // MARK: - Route Drawing

    private func drawRoute() {
        let coords = tripViewModel.routeCoordinates
        guard !coords.isEmpty else { return }

        let line = LineString(coords.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        var source = GeoJSONSource(id: Self.routeSourceID)
        source.data = .geometry(.lineString(line))

        var layer = LineLayer(id: Self.routeLayerID, source: Self.routeSourceID)
        layer.lineColor = .constant(StyleColor(UIColor(hex: "#007AFF")))
        layer.lineWidth = .constant(4)
        layer.lineCap = .constant(.round)
        layer.lineJoin = .constant(.round)

        if mapView.mapboxMap.sourceExists(withId: Self.routeSourceID) {
            try? mapView.mapboxMap.updateGeoJSONSource(withId: Self.routeSourceID,
                                                       geoJSON: .geometry(.lineString(line)))
        } else {
            try? mapView.mapboxMap.addSource(source)
            try? mapView.mapboxMap.addLayer(layer)
        }

        mapView.camera.ease(
            to: mapView.mapboxMap.camera(for: .lineString(line),
                                         padding: UIEdgeInsets(top: 80, left: 60, bottom: 80, right: 60),
                                         bearing: nil,
                                         pitch: nil),
            duration: 1.0
        )
    }
    
    private func hideKeyboard() {
        pickupTextField.resignFirstResponder()
        destinationTextField.resignFirstResponder()

    }

    private func clearTrip() {
        try? mapView.mapboxMap.removeLayer(withId: Self.routeLayerID)
        try? mapView.mapboxMap.removeSource(withId: Self.routeSourceID)
        annotationManager?.annotations = []
        pickupTextField.text = nil
        destinationTextField.text = nil
        hideKeyboard()
        suggestionsTableView.isHidden = true
        tripViewModel.reset()
        UIView.animate(withDuration: 0.3) { self.topView.alpha = 1 }
    }

    // MARK: - Annotations

    private func placePin(coordinate: CLLocationCoordinate2D, id: String, color: UIColor) {
        let image: UIImage = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20)).image { ctx in
            color.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 20, height: 20))
        }
        placePin(coordinate: coordinate, id: id, image: image)
    }

    private func placePin(coordinate: CLLocationCoordinate2D, id: String, image: UIImage) {
        guard let manager = annotationManager else { return }
        var annotation = PointAnnotation(id: id, coordinate: coordinate)
        annotation.image = .init(image: image, name: id)
        annotation.tapHandler = { [weak self] _ in
            guard let self, self.tripViewModel.state != .riding else { return true }
            UIView.animate(withDuration: 0.3) { self.topView.alpha = 1 }
            return true
        }
        manager.annotations = manager.annotations.filter { $0.id != id } + [annotation]
    }

    private func pickupImage() -> UIImage {
        if let data = markerConfig.customImageData, let image = UIImage(data: data) {
            return image
        }
        // No saved preference → fall back to the standard red mappin
        guard UserDefaults.standard.string(forKey: UserDefaultsKeys.Marker.shape) != nil else {
            let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
            return UIImage(systemName: "mappin.fill", withConfiguration: config)?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
        }
        return MarkerImageRenderer.image(for: markerConfig.shape, color: markerConfig.color)
    }

    private func vehicleImage() -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        return UIImage(systemName: tripViewModel.trip.vehicle.icon, withConfiguration: config)?
            .withTintColor(UIColor(hex: "#007AFF"), renderingMode: .alwaysOriginal) ?? UIImage()
    }

    // MARK: - Map Tap

    private func setupMapTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        tap.delegate = self
        mapView.addGestureRecognizer(tap)
    }

    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        guard tripViewModel.state != .riding,
              tripViewModel.state != .routeReady else { return }

        let point = gesture.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: point)

        // Determine target field: respect active field if set, otherwise fall back to what's missing
        let field: SearchField
        if pickupTextField.isFirstResponder {
            field = .pickup
        } else if destinationTextField.isFirstResponder {
            field = .destination
        } else if tripViewModel.trip.pickup == nil {
            field = .pickup
        } else {
            field = .destination
        }

        tripViewModel.reverseGeocode(coordinate: coordinate) { [weak self] result in
            guard let self, let result else { return }
            let location = TripLocation(coordinate: result.coordinate, address: result.address)
            switch field {
            case .pickup:
                self.pickupTextField.text = result.address
                self.tripViewModel.setPickup(location)
            case .destination:
                self.destinationTextField.text = result.address
                self.tripViewModel.setDestination(location)
            }
        }
    }

    // MARK: - Bottom Sheet

    private func showBottomSheet() {
        suggestionsTableView.isHidden = true
        let hostingVC = UIHostingController(rootView: TripBottomSheetView(viewModel: tripViewModel))
        hostingVC.view.backgroundColor = .clear
        if let sheet = hostingVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(hostingVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension MapViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeSearchField = textField === pickupTextField ? .pickup : .destination
        // Show this field's own cached results immediately when switching fields
        let results = searchResults
        suggestionsTableView.isHidden = results.isEmpty
        suggestionsTableView.reloadData()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let query = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        // Clear the other field's pending results so they don't bleed in
        if textField === pickupTextField { destinationResults = [] } else { pickupResults = [] }
        tripViewModel.searchAddress(query: query)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MapViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.address
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.selectionStyle = .none
        var bg = UIBackgroundConfiguration.clear()
        bg.backgroundColor = UIColor(hex: "#1a1f2e").withAlphaComponent(0.20)
        cell.backgroundConfiguration = bg
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Freeze both result and active field before any state changes clear the arrays
        guard indexPath.row < searchResults.count else { return }
        let result = searchResults[indexPath.row]
        let field = activeSearchField
        let location = TripLocation(coordinate: result.coordinate, address: result.address)

        switch field {
        case .pickup:
            pickupTextField.text = result.address
            pickupTextField.resignFirstResponder()
            tripViewModel.setPickup(location)
        case .destination:
            destinationTextField.text = result.address
            destinationTextField.resignFirstResponder()
            tripViewModel.setDestination(location)
        }

        // Clear cache and hide after selection is fully committed
        if field == .pickup { pickupResults = [] } else { destinationResults = [] }
        suggestionsTableView.isHidden = true
        suggestionsTableView.reloadData()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: view)
        if !suggestionsTableView.isHidden && suggestionsTableView.frame.contains(point) { return false }
        if topView.frame.contains(point) { return false }
        return true
    }
}

// MARK: - GestureManagerDelegate

extension MapViewController: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        userIsInteractingWithMap = true
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        if !willAnimate { userIsInteractingWithMap = false }
    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        userIsInteractingWithMap = false
    }
}

// MARK: - Map Overlays

private extension MapViewController {
    func addOverlayLayers() {
        guard let map = mapView?.mapboxMap else { return }
        let sources = map.allSourceIdentifiers.map(\.id)
        let layers = map.allLayerIdentifiers.map(\.id)
        guard sources.contains("composite") else { return }
        if !layers.contains("overlay-buildings") { add3DBuildings(map: map) }
        addTrafficLayer(map: map)
        applyPersistedOverlays(map: map)
    }

    func applyPersistedOverlays(map: MapboxMap) {
        for id in ["buildings", "traffic"] {
            let key = UserDefaultsKeys.Settings.overlayPrefix + id
            let isEnabled = UserDefaults.standard.object(forKey: key) != nil && UserDefaults.standard.bool(forKey: key)
            applyOverlay(id: id, isEnabled: isEnabled, map: map)
        }
    }

    func add3DBuildings(map: MapboxMap) {
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

    func addTrafficLayer(map: MapboxMap) {
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

    func applyOverlay(id: String, isEnabled: Bool) {
        guard let map = mapView?.mapboxMap else { return }
        applyOverlay(id: id, isEnabled: isEnabled, map: map)
    }

    func applyOverlay(id: String, isEnabled: Bool, map: MapboxMap) {
        let value = isEnabled ? "visible" : "none"
        switch id {
        case "buildings": try? map.setLayerProperty(for: "overlay-buildings", property: "visibility", value: value)
        case "traffic":   try? map.setLayerProperty(for: "overlay-traffic",   property: "visibility", value: value)
        default: break
        }
    }
}
