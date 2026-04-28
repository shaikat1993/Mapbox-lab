package com.mapboxvelocity.Core.Protocols

import com.mapbox.geojson.Point
import kotlinx.coroutines.flow.StateFlow

interface LocationServiceProtocol {
    val locationFlow: StateFlow<Point?>
    val lastKnownLocation: Point?
    fun requestLocationUpdates()
    fun stopLocationUpdates()
}
