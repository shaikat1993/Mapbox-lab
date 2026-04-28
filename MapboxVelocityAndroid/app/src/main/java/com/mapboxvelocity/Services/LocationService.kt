package com.mapboxvelocity.Services

import android.annotation.SuppressLint
import android.content.Context
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.mapbox.geojson.Point
import com.mapboxvelocity.Core.Protocols.LocationServiceProtocol
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class LocationService(context: Context) : LocationServiceProtocol {

    private val fusedClient = LocationServices.getFusedLocationProviderClient(context)
    private val _locationFlow = MutableStateFlow<Point?>(null)

    override val locationFlow: StateFlow<Point?> = _locationFlow

    override val lastKnownLocation: Point?
        get() = _locationFlow.value

    private val locationRequest = LocationRequest.Builder(
        Priority.PRIORITY_HIGH_ACCURACY, 2000L
    ).setMinUpdateDistanceMeters(5f).build()

    private val callback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            result.lastLocation?.let { loc ->
                _locationFlow.value = Point.fromLngLat(loc.longitude, loc.latitude)
            }
        }
    }

    @SuppressLint("MissingPermission")
    override fun requestLocationUpdates() {
        // Prime the value with last known before streaming updates
        fusedClient.lastLocation.addOnSuccessListener { loc ->
            loc?.let { _locationFlow.value = Point.fromLngLat(it.longitude, it.latitude) }
        }
        fusedClient.requestLocationUpdates(locationRequest, callback, null)
    }

    override fun stopLocationUpdates() {
        fusedClient.removeLocationUpdates(callback)
    }
}
