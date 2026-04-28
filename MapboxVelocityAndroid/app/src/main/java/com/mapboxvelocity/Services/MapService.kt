package com.mapboxvelocity.Services

import com.mapboxvelocity.Core.Protocols.MapServiceProtocol
import com.mapboxvelocity.Features.Settings.MapStyle
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class MapService : MapServiceProtocol {

    private val _selectedStyle = MutableStateFlow(MapStyle.DARK)
    override val selectedStyle: StateFlow<MapStyle> = _selectedStyle

    private val _overlayState = MutableStateFlow<Map<String, Boolean>>(
        mapOf("buildings" to false, "traffic" to false)
    )
    override val overlayState: StateFlow<Map<String, Boolean>> = _overlayState

    override fun setStyle(style: MapStyle) {
        _selectedStyle.value = style
    }

    override fun setOverlayVisible(id: String, isEnabled: Boolean) {
        _overlayState.value = _overlayState.value.toMutableMap().also { it[id] = isEnabled }
    }
}
