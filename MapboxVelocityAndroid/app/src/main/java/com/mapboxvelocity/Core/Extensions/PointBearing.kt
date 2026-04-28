package com.mapboxvelocity.Core.Extensions

import com.mapbox.geojson.Point
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

fun Point.bearing(to: Point): Double {
    val lat1 = Math.toRadians(this.latitude())
    val lat2 = Math.toRadians(to.latitude())
    val dLon = Math.toRadians(to.longitude() - this.longitude())

    val x = sin(dLon) * cos(lat2)
    val y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

    val bearing = Math.toDegrees(atan2(x, y))
    return (bearing + 360.0) % 360.0
}
