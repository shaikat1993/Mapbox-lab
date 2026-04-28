package com.mapboxvelocity.Features.Map

import com.mapbox.geojson.Point

data class TripLocation(
    val point: Point,
    val address: String
)

enum class VehicleType {
    BIKE, CAR, SCOOTER;

    val title: String get() = when (this) {
        BIKE    -> "Bike"
        CAR     -> "Car"
        SCOOTER -> "Scooter"
    }

    val basePrice: Double get() = when (this) {
        BIKE    -> 77.00
        CAR     -> 99.00
        SCOOTER -> 66.00
    }

    // Emoji icons — Android has no SF Symbols; mirrors iOS icon intent
    val emoji: String get() = when (this) {
        BIKE    -> "🚲"
        CAR     -> "🚗"
        SCOOTER -> "🛵"
    }

    val bearingOffset: Double get() = when (this) {
        CAR             -> 180.0
        BIKE, SCOOTER   -> 90.0
    }
}

enum class PaymentType {
    CASH, MOBILE_PAY;

    val title: String get() = when (this) {
        CASH        -> "Cash"
        MOBILE_PAY  -> "Mobile Pay"
    }
}

sealed class TripState {
    object Idle         : TripState()
    object PickupSet    : TripState()
    object FetchingRoute: TripState()
    object RouteReady   : TripState()
    object Riding       : TripState()
    object RideEnded    : TripState()
    data class Error(val message: String) : TripState()

    override fun equals(other: Any?): Boolean = this === other || this::class == other?.let { it::class }
    override fun hashCode(): Int = this::class.hashCode()
}

data class Trip(
    val pickup: TripLocation?       = null,
    val destination: TripLocation?  = null,
    val vehicle: VehicleType        = VehicleType.CAR,
    val payment: PaymentType        = PaymentType.CASH,
    val distanceMeters: Double      = 0.0,
    val durationSeconds: Double     = 0.0,
    val discount: Double            = 0.0
) {
    val finalPrice: Double get() = vehicle.basePrice - discount

    companion object {
        val empty get() = Trip()
    }
}
