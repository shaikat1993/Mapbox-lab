//
//  GeocodingService.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//
import CoreLocation
import Foundation

final class GeocodingService: GeocodingServiceProtocol {
    private let accessToken: String = {
        Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String ?? ""
    }()

    // ISO 3166-1 alpha-2 country code from device locale (e.g. "BD", "US")
    private var countryCode: String {
        Locale.current.region?.identifier ?? "US"
    }

    func search(query: String,
                completion: @escaping ([GeocodingResult]) -> Void) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.mapbox.com/geocoding/v5/mapbox.places/\(encoded).json?access_token=\(accessToken)&limit=5&language=en&country=\(countryCode)")
        else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if error != nil {
                DispatchQueue.main.async { completion([]) }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let features = json["features"] as? [[String: Any]]
            else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let results: [GeocodingResult] = features.compactMap { Self.parseFeature($0) }
            DispatchQueue.main.async { completion(results) }
        }.resume()
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D,
                        completion: @escaping (GeocodingResult?) -> Void) {
        guard let url = URL(string: "https://api.mapbox.com/geocoding/v5/mapbox.places/\(coordinate.longitude),\(coordinate.latitude).json?access_token=\(accessToken)&limit=1&language=en")
        else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let features = json["features"] as? [[String: Any]],
                  let first = features.first
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let result = Self.parseFeature(first)
            DispatchQueue.main.async { completion(result) }
        }.resume()
    }

    private static func parseFeature(_ feature: [String: Any]) -> GeocodingResult? {
        guard let geometry = feature["geometry"] as? [String: Any],
              let coords = geometry["coordinates"] as? [Double],
              coords.count >= 2
        else { return nil }

        let coordinate = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
        let address = formatAddress(from: feature)
        return GeocodingResult(coordinate: coordinate, address: address)
    }

    // Builds "Street Name 12, City" — matching how Google Maps / Mapbox web show addresses
    private static func formatAddress(from feature: [String: Any]) -> String {
        let streetName   = feature["text"] as? String ?? ""
        let streetNumber = feature["address"] as? String ?? ""

        // street = "Main Street 12" or just "Main Street"
        let street = streetNumber.isEmpty ? streetName : "\(streetName) \(streetNumber)"

        // context array holds neighbourhood, postcode, place (city), region, country
        let context = feature["context"] as? [[String: Any]] ?? []
        let city = context.first(where: { ($0["id"] as? String ?? "").hasPrefix("place.") })?["text"] as? String ?? ""

        // place_name fallback — strip everything after the second comma to drop postcode/region/country
        let placeName = feature["place_name"] as? String ?? ""
        let fallback = placeName.components(separatedBy: ",").prefix(2).joined(separator: ",").trimmingCharacters(in: .whitespaces)

        if !street.isEmpty && !city.isEmpty {
            return "\(street), \(city)"
        } else if !street.isEmpty {
            return street
        } else {
            return fallback
        }
    }
}
