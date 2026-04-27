//
//  RideAnimator.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//

// flow
/*
 1. User picks pickup → sets a pin on map
 2. User picks destination → calls Directions API, draws the route polyline
 3. User selects vehicle + taps Book → tripViewModel.startRide() sets state to .riding
 4. MapViewController sees .riding state → calls rideAnimator.start(along: routeCoordinates)
 5. Every 100ms, RideAnimator fires the next coordinate → MapViewController moves a car/bike annotation along the polyline
 6. When the last coordinate is reached → onCompletion fires → tripViewModel.endRide() → state becomes .rideEnded
 */

import Foundation
import CoreLocation

// This is to mimic the ride sharing flow

final class RideAnimator {
    // Called every tick with the current coordinate and bearing toward next point
    var onCoordinateUpdate: ((_ coordinate: CLLocationCoordinate2D, _ bearing: Double) -> Void)?

    // Called when the animation finishes
    var onCompletion: (() -> Void)?

    private var timer: Timer?
    private var coordinates: [CLLocationCoordinate2D] = []
    private var currentIndex: Int = 0
    // Seconds between each step — controls visual speed
    let stepInterval: TimeInterval = 0.10

    func start(along coordinates: [CLLocationCoordinate2D]) {
        guard coordinates.count > 1 else { return }
        stop()
        self.coordinates = coordinates
        self.currentIndex = 0

        timer = Timer.scheduledTimer(withTimeInterval: stepInterval,
                                     repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard currentIndex < coordinates.count else {
            stop()
            onCompletion?()
            return
        }
        let current = coordinates[currentIndex]
        // Bearing toward next point, or same as last segment if at the end
        let next = currentIndex + 1 < coordinates.count ? coordinates[currentIndex + 1] : current
        let bearing = current.bearing(to: next)
        onCoordinateUpdate?(current, bearing)
        currentIndex += 1
    }
}
