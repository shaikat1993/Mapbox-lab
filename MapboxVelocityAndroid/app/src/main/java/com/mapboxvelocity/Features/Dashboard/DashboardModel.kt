package com.mapboxvelocity.Features.Dashboard

data class DashboardCardModel(
    val icon: String,
    val title: String,
    val subtitle: String,
    val backgroundImage: String,
    val destination: CardDestination
)

enum class CardDestination { MAP_TAB, MARKERS_TAB, SETTINGS_TAB }
