package com.mapboxvelocity.Core.Protocols

import com.mapbox.geojson.Point

data class RouteResult(
    val coordinates: List<Point>,
    val distanceMeters: Double,
    val durationSeconds: Double
)

interface DirectionsServiceProtocol {
    suspend fun fetchRoute(from: Point, to: Point): Result<RouteResult>
}
