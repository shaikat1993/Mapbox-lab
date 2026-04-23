//
//  LocationService.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/22/26.
//

import CoreLocation
import Combine

final class LocationService: NSObject,
                                LocationServiceProtocol,
                             CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocation, Never> ()
    
    var currentLocation: AnyPublisher<CLLocation, Never> {
        subject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
        else {return}
        subject.send(location)
    }
}
