package com.mapboxvelocity.Features.Settings

// Mirrors iOS SettingsModel.swift exactly — same styles, same overlays

enum class MapStyle(val styleUri: String, val title: String, val subtitle: String, val previewIcon: String) {
    STANDARD("mapbox://styles/mapbox/standard",         "Standard",  "High-legibility",                          "map"),
    DARK    ("mapbox://styles/mapbox/dark-v11",          "Dark",      "Kinetic Core",                             "moon"),
    SATELLITE("mapbox://styles/mapbox/satellite-streets-v12", "Satellite", "Orbital imagery",                   "globe"),
    HEATMAP ("mapbox://styles/mapbox/outdoors-v12",     "HeatMap",   "Density view",                             "flame"),
    WOLT    ("mapbox://styles/sadidur25/cmobqf8oo001k01sh5wxo0u08", "Wolt", "Cream base · pastel blocks · courier pins", "restaurant");

    val isFullWidth: Boolean get() = this == WOLT
    val isInspired: Boolean get() = this == WOLT

    companion object {
        fun fromTitle(title: String?) = values().firstOrNull { it.title == title } ?: DARK
    }
}

data class TechnicalOverlay(
    val id: String,
    val title: String,
    val subtitle: String,
    val icon: String,
    val isEnabled: Boolean = false
) {
    companion object {
        val defaults get() = listOf(
            TechnicalOverlay("buildings", "3D Buildings",      "Render volumetric structures", "building"),
            TechnicalOverlay("traffic",   "Real-time Traffic", "Live congestion telemetry",    "directions_car")
        )
    }
}

object SettingsPrefsKeys {
    const val MAP_STYLE      = "selected_map_style"
    const val OVERLAY_PREFIX = "overlay_"
}
