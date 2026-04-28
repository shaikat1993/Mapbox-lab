package com.mapboxvelocity.Features.Map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mapbox.geojson.Point
import com.mapboxvelocity.Core.Models.GeocodingResult
import com.mapboxvelocity.Core.Protocols.DirectionsServiceProtocol
import com.mapboxvelocity.Core.Protocols.GeocodingServiceProtocol
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class TripViewModel(
    private val geocodingService: GeocodingServiceProtocol,
    private val directionsService: DirectionsServiceProtocol
) : ViewModel() {

    private val _trip = MutableStateFlow(Trip.empty)
    val trip: StateFlow<Trip> = _trip

    private val _state = MutableStateFlow<TripState>(TripState.Idle)
    val state: StateFlow<TripState> = _state

    private val _searchResults = MutableStateFlow<List<GeocodingResult>>(emptyList())
    val searchResults: StateFlow<List<GeocodingResult>> = _searchResults

    private val _routeCoordinates = MutableStateFlow<List<Point>>(emptyList())
    val routeCoordinates: StateFlow<List<Point>> = _routeCoordinates

    // Separate caches prevent cross-field contamination — mirrors iOS MapViewController
    private var pickupResults: List<GeocodingResult> = emptyList()
    private var destinationResults: List<GeocodingResult> = emptyList()

    private var searchJob: Job? = null

    // MARK: - Search

    fun searchAddress(query: String, isPickup: Boolean) {
        searchJob?.cancel()
        if (query.isEmpty()) {
            _searchResults.value = emptyList()
            return
        }
        searchJob = viewModelScope.launch {
            delay(300)
            val results = geocodingService.search(query)
            if (isPickup) pickupResults = results else destinationResults = results
            _searchResults.value = results
        }
    }

    fun showResultsForField(isPickup: Boolean) {
        _searchResults.value = if (isPickup) pickupResults else destinationResults
    }

    fun clearResultsForOtherField(isPickup: Boolean) {
        if (isPickup) destinationResults = emptyList()
        else pickupResults = emptyList()
    }

    fun reverseGeocode(point: Point, onResult: (GeocodingResult?) -> Unit) {
        viewModelScope.launch {
            onResult(geocodingService.reverseGeocode(point))
        }
    }

    // MARK: - Trip Setup

    fun setPickup(location: TripLocation) {
        _trip.value = _trip.value.copy(pickup = location)
        _state.value = TripState.PickupSet
        _searchResults.value = emptyList()
        pickupResults = emptyList()
    }

    fun setDestination(location: TripLocation) {
        _trip.value = _trip.value.copy(destination = location)
        _searchResults.value = emptyList()
        destinationResults = emptyList()
        fetchRoute()
    }

    fun selectVehicle(vehicle: VehicleType) {
        _trip.value = _trip.value.copy(vehicle = vehicle)
    }

    fun selectPayment(payment: PaymentType) {
        _trip.value = _trip.value.copy(payment = payment)
    }

    fun startRide() {
        if (_state.value != TripState.RouteReady) return
        _state.value = TripState.Riding
    }

    fun endRide() {
        _state.value = TripState.RideEnded
    }

    fun reset() {
        _trip.value = Trip.empty
        _state.value = TripState.Idle
        _searchResults.value = emptyList()
        _routeCoordinates.value = emptyList()
        pickupResults = emptyList()
        destinationResults = emptyList()
    }

    // MARK: - Private

    private fun fetchRoute() {
        val pickup = _trip.value.pickup ?: return
        val destination = _trip.value.destination ?: return
        _state.value = TripState.FetchingRoute

        viewModelScope.launch {
            directionsService.fetchRoute(pickup.point, destination.point)
                .onSuccess { route ->
                    _trip.value = _trip.value.copy(
                        distanceMeters = route.distanceMeters,
                        durationSeconds = route.durationSeconds
                    )
                    _routeCoordinates.value = route.coordinates
                    _state.value = TripState.RouteReady
                }
                .onFailure { error ->
                    _state.value = TripState.Error(error.message ?: "Route fetch failed")
                }
        }
    }
}
