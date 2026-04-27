//
//  GeocodingServiceProtocol.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//
import CoreLocation

protocol GeocodingServiceProtocol: AnyObject {
    func search(query: String,
                completion: @escaping ([GeocodingResult]) -> Void)
    func reverseGeocode(coordinate: CLLocationCoordinate2D,
                        completion: @escaping (GeocodingResult?) -> Void)
}
