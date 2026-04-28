package com.mapboxvelocity.Core.Protocols

import com.mapboxvelocity.Features.Settings.MapStyle
import kotlinx.coroutines.flow.StateFlow

interface MapServiceProtocol {
    val selectedStyle: StateFlow<MapStyle>
    val overlayState: StateFlow<Map<String, Boolean>>
    fun setStyle(style: MapStyle)
    fun setOverlayVisible(id: String, isEnabled: Boolean)
}
