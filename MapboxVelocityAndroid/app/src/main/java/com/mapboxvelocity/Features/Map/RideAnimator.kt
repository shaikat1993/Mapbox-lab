package com.mapboxvelocity.Features.Map

import android.os.Handler
import android.os.Looper
import com.mapbox.geojson.Point
import com.mapboxvelocity.Core.Extensions.bearing

// Mirrors iOS RideAnimator:
// - Fires every 100ms (stepInterval)
// - Calls onCoordinateUpdate with current position + bearing toward next point
// - Calls onCompletion when last coordinate is reached
class RideAnimator {

    var onCoordinateUpdate: ((point: Point, bearing: Double) -> Unit)? = null
    var onCompletion: (() -> Unit)? = null

    val stepInterval: Long = 100L // ms — matches iOS 0.10s

    private val handler = Handler(Looper.getMainLooper())
    private var coordinates: List<Point> = emptyList()
    private var currentIndex = 0

    private val ticker = object : Runnable {
        override fun run() {
            tick()
        }
    }

    fun start(coordinates: List<Point>) {
        if (coordinates.size < 2) return
        stop()
        this.coordinates = coordinates
        this.currentIndex = 0
        handler.post(ticker)
    }

    fun stop() {
        handler.removeCallbacks(ticker)
    }

    private fun tick() {
        if (currentIndex >= coordinates.size) {
            stop()
            onCompletion?.invoke()
            return
        }
        val current = coordinates[currentIndex]
        val next = if (currentIndex + 1 < coordinates.size) coordinates[currentIndex + 1] else current
        val bearing = current.bearing(next)
        onCoordinateUpdate?.invoke(current, bearing)
        currentIndex++
        handler.postDelayed(ticker, stepInterval)
    }
}
