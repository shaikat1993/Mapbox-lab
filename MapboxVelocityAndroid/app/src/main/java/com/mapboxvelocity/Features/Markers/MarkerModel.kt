package com.mapboxvelocity.Features.Markers

import android.content.Context
import android.graphics.Color
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.byteArrayPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey

enum class MarkerShape(val title: String, val systemIcon: String) {
    PIN("PIN", "mappin"),
    DOT("DOT", "circle.fill"),
    CIRCLE("CIRCLE", "circle"),
    STAR("STAR", "star");

    companion object {
        fun fromRaw(value: String?) = values().firstOrNull { it.name == value } ?: PIN
    }
}

enum class MarkerColor(val hex: String, val argb: Int) {
    WHITE("#FFFFFF",  Color.WHITE),
    GREEN("#4CD964",  Color.parseColor("#4CD964")),
    PINK("#FF6B81",   Color.parseColor("#FF6B81")),
    ORANGE("#FF9500", Color.parseColor("#FF9500")),
    PURPLE("#BF5AF2", Color.parseColor("#BF5AF2")),
    TEAL("#5AC8FA",   Color.parseColor("#5AC8FA"));

    companion object {
        fun fromRaw(value: String?) = values().firstOrNull { it.hex == value } ?: WHITE
    }
}

data class MarkerConfig(
    val label: String = "Secret Spot",
    val shape: MarkerShape = MarkerShape.PIN,
    val color: MarkerColor = MarkerColor.WHITE,
    val customImageData: ByteArray? = null
)

object MarkerPrefsKeys {
    val LABEL      = stringPreferencesKey("marker_label")
    val SHAPE      = stringPreferencesKey("marker_shape")
    val COLOR      = stringPreferencesKey("marker_color")
    val IMAGE_DATA = byteArrayPreferencesKey("marker_image_data")
}
