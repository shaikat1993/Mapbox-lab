package com.mapboxvelocity.Features.Settings

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val dataStore: DataStore<Preferences>,
    private val mapService: com.mapboxvelocity.Core.Protocols.MapServiceProtocol
) : ViewModel() {

    private val _selectedStyle = MutableStateFlow(MapStyle.DARK)
    val selectedStyle: StateFlow<MapStyle> = _selectedStyle

    private val _overlays = MutableStateFlow(TechnicalOverlay.defaults)
    val overlays: StateFlow<List<TechnicalOverlay>> = _overlays

    init {
        viewModelScope.launch { loadSettings() }
    }

    fun selectStyle(style: MapStyle) {
        _selectedStyle.value = style
        viewModelScope.launch {
            dataStore.edit { it[stringPreferencesKey(SettingsPrefsKeys.MAP_STYLE)] = style.title }
        }
        mapService.setStyle(style)
    }

    fun toggleOverlay(id: String, isEnabled: Boolean) {
        _overlays.value = _overlays.value.map {
            if (it.id == id) it.copy(isEnabled = isEnabled) else it
        }
        viewModelScope.launch {
            dataStore.edit { it[booleanPreferencesKey(SettingsPrefsKeys.OVERLAY_PREFIX + id)] = isEnabled }
        }
        mapService.setOverlayVisible(id, isEnabled)
    }

    private suspend fun loadSettings() {
        val prefs = dataStore.data.first()
        val savedTitle = prefs[stringPreferencesKey(SettingsPrefsKeys.MAP_STYLE)]
        _selectedStyle.value = MapStyle.fromTitle(savedTitle)

        _overlays.value = TechnicalOverlay.defaults.map { overlay ->
            val key = booleanPreferencesKey(SettingsPrefsKeys.OVERLAY_PREFIX + overlay.id)
            overlay.copy(isEnabled = prefs[key] ?: false)
        }
    }
}
