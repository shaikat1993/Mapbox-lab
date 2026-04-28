package com.mapboxvelocity.App

import android.app.Application
import com.mapbox.common.MapboxOptions
import com.mapboxvelocity.BuildConfig

class MapboxVelocityApp : Application() {
    lateinit var container: DependencyContainer
        private set

    override fun onCreate() {
        super.onCreate()
        
        // Initialize Mapbox with the access token from BuildConfig
        MapboxOptions.accessToken = BuildConfig.MAPBOX_ACCESS_TOKEN

        container = DependencyContainer(this)
    }
}
