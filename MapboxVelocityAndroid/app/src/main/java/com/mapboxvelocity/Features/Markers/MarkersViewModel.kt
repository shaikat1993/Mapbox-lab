package com.mapboxvelocity.Features.Markers

import android.net.Uri
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MarkersViewModel(
    private val dataStore: DataStore<Preferences>
) : ViewModel() {

    private val _config = MutableStateFlow(MarkerConfig())
    val config: StateFlow<MarkerConfig> = _config

    init {
        viewModelScope.launch { loadSaved() }
    }

    fun updateLabel(label: String) {
        _config.value = _config.value.copy(label = label)
    }

    fun updateShape(shape: MarkerShape) {
        _config.value = _config.value.copy(shape = shape, customImageData = null)
    }

    fun updateColor(color: MarkerColor) {
        _config.value = _config.value.copy(color = color, customImageData = null)
    }

    fun updateCustomImage(data: ByteArray?) {
        _config.value = _config.value.copy(customImageData = data)
    }

    fun save() {
        viewModelScope.launch {
            dataStore.edit { prefs ->
                prefs[MarkerPrefsKeys.LABEL] = _config.value.label
                prefs[MarkerPrefsKeys.SHAPE] = _config.value.shape.name
                prefs[MarkerPrefsKeys.COLOR] = _config.value.color.hex
                _config.value.customImageData?.let { prefs[MarkerPrefsKeys.IMAGE_DATA] = it }
            }
        }
    }

    private suspend fun loadSaved() {
        val prefs = dataStore.data.first()
        _config.value = MarkerConfig(
            label = prefs[MarkerPrefsKeys.LABEL] ?: "Secret Spot",
            shape = MarkerShape.fromRaw(prefs[MarkerPrefsKeys.SHAPE]),
            color = MarkerColor.fromRaw(prefs[MarkerPrefsKeys.COLOR]),
            customImageData = prefs[MarkerPrefsKeys.IMAGE_DATA]
        )
    }
}
