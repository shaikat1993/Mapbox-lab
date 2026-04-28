package com.mapboxvelocity.App

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.remember
import androidx.core.content.ContextCompat

class MainActivity : ComponentActivity() {

    private val locationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { grants ->
        if (grants.values.any { it }) {
            container.locationService.requestLocationUpdates()
        }
    }

    private val container get() = (application as MapboxVelocityApp).container

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestLocationIfNeeded()

        setContent {
            val tripViewModel = remember { container.makeTripViewModel() }
            val markersViewModel = remember { container.makeMarkersViewModel() }
            val settingsViewModel = remember { container.makeSettingsViewModel() }

            AppNavigation(
                tripViewModel = tripViewModel,
                markersViewModel = markersViewModel,
                settingsViewModel = settingsViewModel,
                locationService = container.locationService,
                mapService = container.mapService,
                onLocationPermissionNeeded = { requestLocationIfNeeded() }
            )
        }
    }

    private fun requestLocationIfNeeded() {
        val fine = Manifest.permission.ACCESS_FINE_LOCATION
        val coarse = Manifest.permission.ACCESS_COARSE_LOCATION
        if (ContextCompat.checkSelfPermission(this, fine) == PackageManager.PERMISSION_GRANTED) {
            container.locationService.requestLocationUpdates()
        } else {
            locationPermissionLauncher.launch(arrayOf(fine, coarse))
        }
    }
}
