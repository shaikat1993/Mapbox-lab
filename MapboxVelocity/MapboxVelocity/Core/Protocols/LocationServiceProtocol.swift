//
//  LocationServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/21/26.
//

import CoreLocation
import Combine

protocol LocationServiceProtocol: AnyObject {
    var currentLocation: AnyPublisher<CLLocation, Never> { get }
    var lastKnownLocation: CLLocation? { get }
    func requestPermission()
    func startUpdating()
    func stopUpdating()
}

