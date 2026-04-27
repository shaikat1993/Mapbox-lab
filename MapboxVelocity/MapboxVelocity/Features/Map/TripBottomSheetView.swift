//
//  TripBottomSheetView.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/26/26.
//

import SwiftUI
import CoreLocation

struct TripBottomSheetView: View {

    @ObservedObject var viewModel: TripViewModel

    var body: some View {
        VStack(spacing: 0) {
            handle

            VehiclePickerSection(viewModel: viewModel)

            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.vertical, 12)

            PriceSummarySection(viewModel: viewModel)

            BookButton(viewModel: viewModel)
                .padding(.top, 12)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor(hex: "#1a1f2e")))
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.white.opacity(0.3))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }
}

// MARK: - Vehicle Picker

private struct VehiclePickerSection: View {
    @ObservedObject var viewModel: TripViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a ride")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(VehicleType.allCases, id: \.self) { vehicle in
                    VehicleCard(
                        vehicle: vehicle,
                        isSelected: viewModel.trip.vehicle == vehicle
                    ) {
                        viewModel.selectVehicle(vehicle)
                    }
                }
            }
        }
    }
}

private struct VehicleCard: View {
    let vehicle: VehicleType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: vehicle.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(UIColor(hex: "#007AFF")) : .white)

                Text(vehicle.title)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color(UIColor(hex: "#007AFF")) : .white.opacity(0.7))

                Text(String(format: "$%.0f", vehicle.basePrice))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(UIColor(hex: "#007AFF")).opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(UIColor(hex: "#007AFF")) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Price Summary

private struct PriceSummarySection: View {
    @ObservedObject var viewModel: TripViewModel

    private var distanceKm: String {
        String(format: "%.1f km", viewModel.trip.distanceMeters / 1000)
    }

    private var duration: String {
        let minutes = Int(viewModel.trip.durationSeconds / 60)
        return "\(minutes) min"
    }

    var body: some View {
        VStack(spacing: 8) {
            row(label: "Distance", value: distanceKm)
            row(label: "Duration", value: duration)
            row(label: "Discount", value: String(format: "-$%.0f", viewModel.trip.discount))

            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.vertical, 4)

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "$%.0f", viewModel.trip.finalPrice))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor(hex: "#34C759")))
            }
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Book Button

private struct BookButton: View {
    @ObservedObject var viewModel: TripViewModel

    var body: some View {
        Button {
            viewModel.startRide()
        } label: {
            Text("Book \(viewModel.trip.vehicle.title)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(UIColor(hex: "#007AFF")))
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.state != .routeReady)
        .opacity(viewModel.state == .routeReady ? 1 : 0.4)
    }
}

#if DEBUG
private final class MockGeocodingService: GeocodingServiceProtocol {
    func search(query: String, completion: @escaping ([GeocodingResult]) -> Void) {
        completion([])
    }
    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (GeocodingResult?) -> Void) {
        completion(nil)
    }
}

private final class MockDirectionsService: DirectionsServiceProtocol {
    func fetchRoute(from: CLLocationCoordinate2D,
                    to: CLLocationCoordinate2D,
                    completion: @escaping (Result<RouteResult, Error>) -> Void) {
        completion(.success(RouteResult(coordinates: [], distanceMeters: 4200, durationSeconds: 720)))
    }
}

#Preview {
    TripBottomSheetView(viewModel: TripViewModel(
        geocodingService: MockGeocodingService(),
        directionsService: MockDirectionsService()
    ))
}
#endif
