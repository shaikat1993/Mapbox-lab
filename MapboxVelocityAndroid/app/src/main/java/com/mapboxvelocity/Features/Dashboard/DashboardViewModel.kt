package com.mapboxvelocity.Features.Dashboard

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class DashboardViewModel : ViewModel() {

    private val _cards = MutableStateFlow<List<DashboardCardModel>>(emptyList())
    val cards: StateFlow<List<DashboardCardModel>> = _cards

    init { loadCards() }

    private fun loadCards() {
        _cards.value = listOf(
            DashboardCardModel(
                icon = "ride_icon",
                title = "Live Ride",
                subtitle = "Here is a mock Live Ride animation",
                backgroundImage = "live_ride",
                destination = CardDestination.MAP_TAB
            ),
            DashboardCardModel(
                icon = "marker_icon",
                title = "Marker Management",
                subtitle = "Here we can update or change the marker in the Map",
                backgroundImage = "markers",
                destination = CardDestination.MARKERS_TAB
            ),
            DashboardCardModel(
                icon = "settings_icon",
                title = "Settings",
                subtitle = "Here we can change the Map Style",
                backgroundImage = "settings",
                destination = CardDestination.SETTINGS_TAB
            )
        )
    }
}
