//
//  DirectionsServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//
import CoreLocation

protocol DirectionsServiceProtocol: AnyObject {
    func fetchRoute(from: CLLocationCoordinate2D,
                    to: CLLocationCoordinate2D,
                    completion: @escaping (Result<RouteResult, Error>) -> Void)
}
