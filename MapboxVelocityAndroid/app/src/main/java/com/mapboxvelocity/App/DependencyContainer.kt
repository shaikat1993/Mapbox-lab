package com.mapboxvelocity.App

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.preferencesDataStore
import com.mapboxvelocity.Features.Map.TripViewModel
import com.mapboxvelocity.Features.Markers.MarkersViewModel
import com.mapboxvelocity.Features.Settings.SettingsViewModel
import com.mapboxvelocity.Services.DirectionsService
import com.mapboxvelocity.Services.GeocodingService
import com.mapboxvelocity.Services.LocationService
import com.mapboxvelocity.Services.MapService
import okhttp3.OkHttpClient

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "velocity_prefs")

// Composition root — the only place concrete types are instantiated
class DependencyContainer(context: Context) {

    private val appContext = context.applicationContext

    private val httpClient = OkHttpClient()
    private val geocodingService = GeocodingService(httpClient)
    private val directionsService = DirectionsService(httpClient)
    val mapService = MapService()
    val locationService = LocationService(appContext)

    fun makeTripViewModel() = TripViewModel(geocodingService, directionsService)

    fun makeMarkersViewModel() = MarkersViewModel(appContext.dataStore)

    fun makeSettingsViewModel() = SettingsViewModel(appContext.dataStore, mapService)
}
