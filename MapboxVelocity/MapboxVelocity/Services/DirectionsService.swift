//
//  DirectionsService.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//

import Foundation
import CoreLocation

struct RouteResult {
    let coordinates: [CLLocationCoordinate2D]
    let distanceMeters: Double
    let durationSeconds: Double
}

final class DirectionsService: DirectionsServiceProtocol {

    private let accessToken: String = {
        Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String ?? ""
    }()

    func fetchRoute(from: CLLocationCoordinate2D,
                    to: CLLocationCoordinate2D,
                    completion: @escaping (Result<RouteResult, Error>) -> Void) {

        let urlString = "https://api.mapbox.com/directions/v5/mapbox/driving/\(from.longitude),\(from.latitude);\(to.longitude),\(to.latitude)?access_token=\(accessToken)&geometries=geojson&overview=full"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "DirectionsService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let routes = json["routes"] as? [[String: Any]],
                  let first = routes.first,
                  let geometry = first["geometry"] as? [String: Any],
                  let coordArrays = geometry["coordinates"] as? [[Double]],
                  let distance = first["distance"] as? Double,
                  let duration = first["duration"] as? Double
            else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "DirectionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No route found"])))
                }
                return
            }

            // Mapbox returns [longitude, latitude] — same as Geocoding
            let coordinates = coordArrays.map {
                CLLocationCoordinate2D(latitude: $0[1],
                                       longitude: $0[0])
            }

            let result = RouteResult(coordinates: coordinates,
                                     distanceMeters: distance,
                                     durationSeconds: duration)

            DispatchQueue.main.async { completion(.success(result)) }
        }.resume()
    }
}
