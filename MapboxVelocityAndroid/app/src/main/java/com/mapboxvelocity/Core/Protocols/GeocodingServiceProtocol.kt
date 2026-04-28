package com.mapboxvelocity.Core.Protocols

import com.mapbox.geojson.Point
import com.mapboxvelocity.Core.Models.GeocodingResult

interface GeocodingServiceProtocol {
    suspend fun search(query: String): List<GeocodingResult>
    suspend fun reverseGeocode(point: Point): GeocodingResult?
}
