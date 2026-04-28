package com.mapboxvelocity.Core.Models

import com.mapbox.geojson.Point

data class GeocodingResult(
    val point: Point,
    val address: String
)
