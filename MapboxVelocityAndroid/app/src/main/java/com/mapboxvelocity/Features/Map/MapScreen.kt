package com.mapboxvelocity.Features.Map

import android.graphics.BitmapFactory
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.mapbox.bindgen.Value
import com.mapbox.geojson.Point
import com.mapbox.maps.CameraOptions
import com.mapbox.maps.EdgeInsets
import com.mapbox.maps.MapboxExperimental
import com.mapbox.maps.extension.compose.MapEffect
import com.mapbox.maps.extension.compose.MapboxMap
import com.mapbox.maps.extension.compose.animation.viewport.rememberMapViewportState
import com.mapbox.maps.extension.compose.annotation.generated.PointAnnotation
import com.mapbox.maps.extension.compose.annotation.generated.PolylineAnnotation
import com.mapbox.maps.extension.compose.annotation.rememberIconImage
import com.mapbox.maps.extension.compose.style.MapStyle
import com.mapbox.maps.extension.style.layers.properties.generated.LineJoin
import com.mapbox.maps.plugin.gestures.OnMoveListener
import com.mapbox.maps.plugin.gestures.gestures
import com.mapboxvelocity.Core.Design.VelocityDesignSystem
import com.mapboxvelocity.Core.Protocols.MapServiceProtocol
import com.mapboxvelocity.Features.Markers.MarkerImageRenderer
import com.mapboxvelocity.Features.Markers.MarkersViewModel
import com.mapboxvelocity.Services.LocationService

private const val OVERLAY_BUILDINGS = "overlay-buildings"
private const val OVERLAY_TRAFFIC   = "overlay-traffic"

@OptIn(MapboxExperimental::class)
@Composable
fun MapScreen(
    viewModel: TripViewModel,
    locationService: LocationService,
    mapService: MapServiceProtocol,
    markersViewModel: MarkersViewModel,
    onLocationPermissionNeeded: () -> Unit
) {
    val ds = VelocityDesignSystem
    val context = LocalContext.current
    val trip by viewModel.trip.collectAsStateWithLifecycle()
    val state by viewModel.state.collectAsStateWithLifecycle()
    val searchResults by viewModel.searchResults.collectAsStateWithLifecycle()
    val routeCoordinates by viewModel.routeCoordinates.collectAsStateWithLifecycle()
    val locationPoint by locationService.locationFlow.collectAsStateWithLifecycle()
    val selectedStyle by mapService.selectedStyle.collectAsStateWithLifecycle()
    val overlayState by mapService.overlayState.collectAsStateWithLifecycle()
    val markerConfig by markersViewModel.config.collectAsStateWithLifecycle()

    var pickupText by remember { mutableStateOf("") }
    var destinationText by remember { mutableStateOf("") }
    var activeFieldIsPickup by remember { mutableStateOf(true) }
    var showResults by remember { mutableStateOf(false) }
    // Mirrors iOS userIsInteractingWithMap — suppress camera follow while user pans
    var userIsInteracting by remember { mutableStateOf(false) }

    val viewportState = rememberMapViewportState {
        setCameraOptions {
            center(Point.fromLngLat(23.7610, 61.4978))
            zoom(12.0)
        }
    }

    // Center on first location fix — mirrors iOS viewDidAppear ease
    LaunchedEffect(locationPoint) {
        locationPoint?.let {
            viewportState.easeTo(CameraOptions.Builder().center(it).zoom(14.0).build())
        }
    }

    val rideAnimator = remember { RideAnimator() }
    var vehiclePoint by remember { mutableStateOf<Point?>(null) }
    var vehicleBearing by remember { mutableStateOf(0.0) }

    LaunchedEffect(state) {
        when (state) {
            TripState.RouteReady -> rideAnimator.stop()
            TripState.Riding -> {
                rideAnimator.onCoordinateUpdate = { point, bearing ->
                    vehiclePoint = point
                    vehicleBearing = bearing - trip.vehicle.bearingOffset
                    // Mirror iOS: skip camera follow when user is panning
                    if (!userIsInteracting) {
                        viewportState.easeTo(
                            CameraOptions.Builder().center(point).zoom(15.0).build()
                        )
                    }
                }
                rideAnimator.onCompletion = { viewModel.endRide() }
                rideAnimator.start(viewModel.routeCoordinates.value)
            }
            TripState.RideEnded -> {
                // Mirrors iOS rideEnded → clearTrip() → tripViewModel.reset()
                rideAnimator.stop()
                vehiclePoint = null
                viewModel.reset()
            }
            TripState.Idle -> {
                rideAnimator.stop()
                vehiclePoint = null
                pickupText = ""
                destinationText = ""
                showResults = false
            }
            else -> rideAnimator.stop()
        }
    }

    // Build pickup icon from saved MarkerConfig — mirrors iOS pickupImage()
    val pickupBitmap = remember(markerConfig) {
        val customData = markerConfig.customImageData
        if (customData != null) {
            BitmapFactory.decodeByteArray(customData, 0, customData.size)
        } else {
            MarkerImageRenderer.image(context, markerConfig.shape, markerConfig.color, size = 88)
        }
    }

    val styleUri = selectedStyle.styleUri

    val pickupIcon = rememberIconImage(
        key = "pickup_${markerConfig.shape}_${markerConfig.color}",
        painter = androidx.compose.ui.graphics.painter.BitmapPainter(pickupBitmap.asImageBitmap())
    )
    val destinationIcon = rememberIconImage(com.mapboxvelocity.R.drawable.ic_destination_dot)
    val vehicleIcon = rememberIconImage(com.mapboxvelocity.R.drawable.ic_vehicle)

    Box(modifier = Modifier.fillMaxSize()) {

        MapboxMap(
            modifier = Modifier.fillMaxSize(),
            mapViewportState = viewportState,
            style = { MapStyle(style = styleUri) },
            onMapClickListener = { point ->
                // Block map tap when suggestions are showing
                if (showResults) return@MapboxMap false
                if (state != TripState.Riding && state != TripState.RouteReady) {
                    viewModel.reverseGeocode(point) { result ->
                        result?.let {
                            val location = TripLocation(it.point, it.address)
                            if (activeFieldIsPickup || trip.pickup == null) {
                                pickupText = it.address
                                viewModel.setPickup(location)
                                if (trip.pickup != null) activeFieldIsPickup = false
                            } else {
                                destinationText = it.address
                                viewModel.setDestination(location)
                            }
                            showResults = false
                        }
                    }
                }
                false
            }
        ) {
            // Register gesture listeners once — mirrors iOS GestureManagerDelegate
            MapEffect(Unit) { mapView ->
                mapView.gestures.addOnMoveListener(object : OnMoveListener {
                    override fun onMoveBegin(detector: com.mapbox.android.gestures.MoveGestureDetector) {
                        userIsInteracting = true
                    }
                    override fun onMove(detector: com.mapbox.android.gestures.MoveGestureDetector): Boolean = false
                    override fun onMoveEnd(detector: com.mapbox.android.gestures.MoveGestureDetector) {
                        userIsInteracting = false
                    }
                })
            }

            // Add overlay layers on style load — mirrors iOS addOverlayLayers()
            // Keyed on styleUri so it re-runs when the user switches map style
            MapEffect(styleUri) { mapView ->
                val map = mapView.mapboxMap
                map.subscribeStyleLoaded {
                    map.getStyle { style ->
                        if (!style.styleSourceExists("composite")) return@getStyle

                        // 3D Buildings — mirrors iOS add3DBuildings()
                        if (!style.styleLayerExists(OVERLAY_BUILDINGS)) {
                            style.addStyleLayer(
                                parameters = Value.fromJson("""
                                {
                                  "id": "$OVERLAY_BUILDINGS",
                                  "type": "fill-extrusion",
                                  "source": "composite",
                                  "source-layer": "building",
                                  "filter": ["==", ["get", "extrude"], "true"],
                                  "paint": {
                                    "fill-extrusion-color": "#adc6ff",
                                    "fill-extrusion-height": ["get", "height"],
                                    "fill-extrusion-base": ["get", "min_height"],
                                    "fill-extrusion-opacity": 0.8
                                  }
                                }
                                """.trimIndent()).value!!,
                                position = null
                            )
                        }

                        // Traffic — mirrors iOS addTrafficLayer()
                        if (!style.styleSourceExists("traffic-source")) {
                            style.addStyleSource(
                                sourceId = "traffic-source",
                                properties = Value.fromJson("""
                                {"type":"vector","url":"mapbox://mapbox.mapbox-traffic-v1"}
                                """.trimIndent()).value!!
                            )
                        }
                        if (!style.styleLayerExists(OVERLAY_TRAFFIC)) {
                            style.addStyleLayer(
                                parameters = Value.fromJson("""
                                {
                                  "id": "$OVERLAY_TRAFFIC",
                                  "type": "line",
                                  "source": "traffic-source",
                                  "source-layer": "traffic",
                                  "paint": {
                                    "line-width": 2.5,
                                    "line-color": [
                                      "match", ["get", "congestion"],
                                      "low",      "#53e16f",
                                      "moderate", "#f4a261",
                                      "heavy",    "#e63946",
                                      "severe",   "#9b2226",
                                      "#53e16f"
                                    ]
                                  }
                                }
                                """.trimIndent()).value!!,
                                position = null
                            )
                        }

                        // Apply current overlay visibility after layers are added
                        applyOverlayVisibility(style, overlayState)
                    }
                }
            }

            // React to overlay toggle — mirrors iOS applyOverlay(id:isEnabled:)
            MapEffect(overlayState) { mapView ->
                mapView.mapboxMap.getStyle { style ->
                    applyOverlayVisibility(style, overlayState)
                }
            }

            // Fit both pins in view when route is ready — mirrors iOS camera(for: lineString, padding:)
            MapEffect(state) { mapView ->
                if (state == TripState.RouteReady && routeCoordinates.size >= 2) {
                    val camera = mapView.mapboxMap.cameraForCoordinates(
                        coordinates = routeCoordinates,
                        coordinatesPadding = EdgeInsets(80.0, 60.0, 300.0, 60.0), // extra bottom for sheet
                        bearing = null,
                        pitch = null
                    )
                    viewportState.easeTo(camera)
                }
            }

            // Route polyline — blue, 4dp, round joins — mirrors iOS drawRoute()
            if (routeCoordinates.size >= 2) {
                PolylineAnnotation(points = routeCoordinates) {
                    lineColor = ds.primaryColor
                    lineWidth = 4.0
                    lineOpacity = 1.0
                    lineJoin = LineJoin.ROUND
                }
            }

            // Pickup pin — uses MarkerConfig bitmap, mirrors iOS placePin with pickupImage()
            trip.pickup?.let { pickup ->
                PointAnnotation(point = pickup.point) {
                    iconImage = pickupIcon
                    iconSize = 0.5
                }
            }

            // Destination pin — red dot, mirrors iOS placePin with red color
            trip.destination?.let { dest ->
                PointAnnotation(point = dest.point) {
                    iconImage = destinationIcon
                    iconSize = 0.5
                }
            }

            // Vehicle annotation during ride
            vehiclePoint?.let { vp ->
                PointAnnotation(point = vp) {
                    iconImage = vehicleIcon
                    iconSize = 0.6
                    iconRotate = vehicleBearing
                }
            }
        }

        // Search panel — hidden when route ready or riding, mirrors iOS topView.alpha = 0
        if (state != TripState.RouteReady && state != TripState.Riding) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.TopCenter)
                    .padding(16.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(ds.cardColor.copy(alpha = 0.95f), RoundedCornerShape(16.dp))
                        .padding(8.dp)
                ) {
                    SearchField(
                        value = pickupText,
                        placeholder = "Pickup location",
                        onValueChange = {
                            pickupText = it
                            viewModel.searchAddress(it, isPickup = true)
                        },
                        onFocused = {
                            activeFieldIsPickup = true
                            showResults = true
                            viewModel.showResultsForField(isPickup = true)
                        }
                    )
                    HorizontalDivider(color = Color.White.copy(alpha = 0.08f))
                    SearchField(
                        value = destinationText,
                        placeholder = "Where to?",
                        onValueChange = {
                            destinationText = it
                            viewModel.searchAddress(it, isPickup = false)
                        },
                        onFocused = {
                            activeFieldIsPickup = false
                            showResults = true
                            viewModel.showResultsForField(isPickup = false)
                        }
                    )
                }

                // Suggestions — mirrors iOS suggestionsTableView
                if (showResults && searchResults.isNotEmpty()) {
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(
                                ds.cardColor.copy(alpha = 0.95f),
                                RoundedCornerShape(bottomStart = 12.dp, bottomEnd = 12.dp)
                            )
                    ) {
                        items(searchResults) { result ->
                            Text(
                                text = result.address,
                                color = Color.White,
                                style = VelocityDesignSystem.Typography.caption,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable {
                                        val location = TripLocation(result.point, result.address)
                                        if (activeFieldIsPickup) {
                                            pickupText = result.address
                                            viewModel.setPickup(location)
                                            activeFieldIsPickup = false
                                        } else {
                                            destinationText = result.address
                                            viewModel.setDestination(location)
                                        }
                                        showResults = false
                                    }
                                    .padding(horizontal = 16.dp, vertical = 12.dp)
                            )
                            HorizontalDivider(color = Color.White.copy(alpha = 0.08f))
                        }
                    }
                }
            }
        }

        // Location FAB — mirrors iOS setupLocationButton (bottom-right, above tab bar)
        FloatingActionButton(
            onClick = {
                locationPoint?.let {
                    viewportState.easeTo(CameraOptions.Builder().center(it).zoom(15.0).build())
                } ?: onLocationPermissionNeeded()
            },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(bottom = 96.dp, end = 16.dp)
                .size(44.dp),
            containerColor = ds.cardColor,
            shape = CircleShape,
            elevation = FloatingActionButtonDefaults.elevation(4.dp)
        ) {
            Icon(
                imageVector = Icons.Default.LocationOn,
                contentDescription = "My Location",
                tint = ds.primaryColor,
                modifier = Modifier.size(20.dp)
            )
        }

        // Bottom sheet — shown only when route ready; dismissed on Book (riding), mirrors iOS dismiss(animated:)
        if (state == TripState.RouteReady) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
            ) {
                TripBottomSheet(viewModel = viewModel)
            }
        }
    }
}

private fun applyOverlayVisibility(
    style: com.mapbox.maps.Style,
    overlayState: Map<String, Boolean>
) {
    val buildingsVal = if (overlayState["buildings"] == true) "visible" else "none"
    val trafficVal   = if (overlayState["traffic"]   == true) "visible" else "none"
    runCatching { style.setStyleLayerProperty(OVERLAY_BUILDINGS, "visibility", Value(buildingsVal)) }
    runCatching { style.setStyleLayerProperty(OVERLAY_TRAFFIC,   "visibility", Value(trafficVal)) }
}

@Composable
private fun SearchField(
    value: String,
    placeholder: String,
    onValueChange: (String) -> Unit,
    onFocused: () -> Unit
) {
    val ds = VelocityDesignSystem
    TextField(
        value = value,
        onValueChange = onValueChange,
        placeholder = {
            Text(placeholder, color = ds.textSecondary, style = VelocityDesignSystem.Typography.caption)
        },
        modifier = Modifier
            .fillMaxWidth()
            .onFocusChanged { if (it.isFocused) onFocused() },
        singleLine = true,
        colors = TextFieldDefaults.colors(
            focusedContainerColor = Color.Transparent,
            unfocusedContainerColor = Color.Transparent,
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            focusedIndicatorColor = Color.Transparent,
            unfocusedIndicatorColor = Color.Transparent,
            cursorColor = ds.primaryColor
        ),
        textStyle = VelocityDesignSystem.Typography.caption
    )
}
