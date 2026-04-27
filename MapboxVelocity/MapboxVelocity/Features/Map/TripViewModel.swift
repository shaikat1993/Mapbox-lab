//
//  TripViewModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//
import Foundation
import CoreLocation
import Combine

final class TripViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var trip: Trip = .empty
    @Published private(set) var state: TripState = .idle
    @Published private(set) var searchResults: [GeocodingResult] = []
    @Published private(set) var routeCoordinates: [CLLocationCoordinate2D] = []

    // MARK: - Dependencies

    private let geocodingService: GeocodingServiceProtocol
    private let directionsService: DirectionsServiceProtocol
    private var searchDebounceTimer: Timer?

    init(geocodingService: GeocodingServiceProtocol,
         directionsService: DirectionsServiceProtocol) {
        self.geocodingService = geocodingService
        self.directionsService = directionsService
    }

    // MARK: - Search

    func searchAddress(query: String) {
        searchDebounceTimer?.invalidate()
        guard !query.isEmpty else { searchResults = []; return }
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.geocodingService.search(query: query) { results in
                self?.searchResults = results
            }
        }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D,
                        completion: @escaping (GeocodingResult?) -> Void) {
        geocodingService.reverseGeocode(coordinate: coordinate, completion: completion)
    }

    // MARK: - Trip Setup

    func setPickup(_ location: TripLocation) {
        trip.pickup = location
        state = .pickupSet
        searchResults = []
    }

    func setDestination(_ location: TripLocation) {
        trip.destination = location
        searchResults = []
        fetchRoute()
    }

    func selectVehicle(_ vehicle: VehicleType) { trip.vehicle = vehicle }
    func selectPayment(_ payment: PaymentType) { trip.payment = payment }

    func startRide() {
        guard state == .routeReady else { return }
        state = .riding
    }

    func endRide() { state = .rideEnded }

    func reset() {
        trip = .empty
        state = .idle
        searchResults = []
        routeCoordinates = []
    }

    // MARK: - Private

    private func fetchRoute() {
        guard let pickup = trip.pickup, let destination = trip.destination else { return }
        state = .fetchingRoute

        directionsService.fetchRoute(from: pickup.coordinate,
                                     to: destination.coordinate) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let route):
                self.trip.distanceMeters = route.distanceMeters
                self.trip.durationSeconds = route.durationSeconds
                self.routeCoordinates = route.coordinates
                self.state = .routeReady
            case .failure(let error):
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
