//
//  TripModel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//

import CoreLocation

struct TripLocation {
    let coordinate: CLLocationCoordinate2D
    let address: String
}

enum VehicleType: CaseIterable, Hashable {
    case bike
    case car
    case scooter

    var title: String {
        switch self {
        case .bike:    "Bike"
        case .car:     "Car"
        case .scooter: "Scooter"
        }
    }

    var basePrice: Double {
        switch self {
        case .bike:    77.00
        case .car:     99.00
        case .scooter: 66.00
        }
    }

    var icon: String {
        switch self {
        case .bike:    "bicycle"
        case .car:     "car.fill"
        case .scooter: "scooter"
        }
    }

    // Degrees to subtract from bearing so the SF symbol faces north at 0°
    var bearingOffset: Double {
        switch self {
        case .car:           180  // car.fill faces left (west)
        case .bike, .scooter: 90  // bicycle/scooter face right (east)
        }
    }
}

enum PaymentType {
    case cash
    case mobilePay
}

enum TripState: Equatable {
    case idle
    case pickupSet
    case fetchingRoute
    case routeReady
    case riding
    case rideEnded
    case error(String)
}

struct Trip {
    var pickup: TripLocation?
    var destination: TripLocation?
    var vehicle: VehicleType
    var payment: PaymentType
    var distanceMeters: Double
    var durationSeconds: Double
    var discount: Double

    var finalPrice: Double { vehicle.basePrice - discount }

    static var empty: Trip {
        Trip(pickup: nil, destination: nil, vehicle: .car,
             payment: .cash, distanceMeters: 0, durationSeconds: 0, discount: 0)
    }
}
