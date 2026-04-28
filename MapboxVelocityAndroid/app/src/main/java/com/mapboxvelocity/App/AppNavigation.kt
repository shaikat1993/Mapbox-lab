package com.mapboxvelocity.App

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.PinDrop
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.mapboxvelocity.Core.Design.VelocityDesignSystem
import com.mapboxvelocity.Core.Protocols.MapServiceProtocol
import com.mapboxvelocity.Features.Dashboard.DashboardScreen
import com.mapboxvelocity.Features.Dashboard.CardDestination
import com.mapboxvelocity.Features.Map.MapScreen
import com.mapboxvelocity.Features.Map.TripViewModel
import com.mapboxvelocity.Features.Markers.MarkersScreen
import com.mapboxvelocity.Features.Markers.MarkersViewModel
import com.mapboxvelocity.Features.Settings.SettingsScreen
import com.mapboxvelocity.Features.Settings.SettingsViewModel
import com.mapboxvelocity.Services.LocationService

sealed class Screen(val route: String, val label: String, val icon: ImageVector) {
    object Map : Screen("map", "Map", Icons.Default.Map)
    object Dashboard : Screen("dashboard", "Dashboard", Icons.Default.Speed)
    object Markers : Screen("markers", "Markers", Icons.Default.PinDrop)
    object Settings : Screen("settings", "Settings", Icons.Default.Settings)
}

@Composable
fun AppNavigation(
    tripViewModel: TripViewModel,
    markersViewModel: MarkersViewModel,
    settingsViewModel: SettingsViewModel,
    locationService: LocationService,
    mapService: MapServiceProtocol,
    onLocationPermissionNeeded: () -> Unit
) {
    val ds = VelocityDesignSystem
    val navController = rememberNavController()
    val tabs = listOf(Screen.Dashboard, Screen.Map, Screen.Markers, Screen.Settings)

    Scaffold(
        bottomBar = {
            NavigationBar(containerColor = ds.surfaceColor) {
                val navBackStack by navController.currentBackStackEntryAsState()
                val current = navBackStack?.destination

                tabs.forEach { screen ->
                    val selected = current?.hierarchy?.any { it.route == screen.route } == true
                    NavigationBarItem(
                        selected = selected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ds.primaryColor,
                            selectedTextColor = ds.primaryColor,
                            unselectedIconColor = ds.textSecondary,
                            unselectedTextColor = ds.textSecondary,
                            indicatorColor = ds.primaryColor.copy(alpha = 0.12f)
                        )
                    )
                }
            }
        },
        containerColor = ds.backgroundColor
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Map.route) {
                MapScreen(
                    viewModel = tripViewModel,
                    locationService = locationService,
                    mapService = mapService,
                    markersViewModel = markersViewModel,
                    onLocationPermissionNeeded = onLocationPermissionNeeded
                )
            }
            composable(Screen.Dashboard.route) {
                DashboardScreen(onNavigate = { destination ->
                    val route = when (destination) {
                        CardDestination.MAP_TAB -> Screen.Map.route
                        CardDestination.MARKERS_TAB -> Screen.Markers.route
                        CardDestination.SETTINGS_TAB -> Screen.Settings.route
                    }
                    navController.navigate(route) {
                        popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                        launchSingleTop = true
                        restoreState = true
                    }
                })
            }
            composable(Screen.Markers.route) { MarkersScreen(viewModel = markersViewModel) }
            composable(Screen.Settings.route) { SettingsScreen(viewModel = settingsViewModel) }
        }
    }
}
