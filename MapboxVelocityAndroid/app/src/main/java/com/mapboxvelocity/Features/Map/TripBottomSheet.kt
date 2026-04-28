package com.mapboxvelocity.Features.Map

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.mapboxvelocity.Core.Design.VelocityDesignSystem
import kotlin.math.roundToInt

@Composable
fun TripBottomSheet(viewModel: TripViewModel) {
    val ds = VelocityDesignSystem
    val trip by viewModel.trip.collectAsStateWithLifecycle()
    val state by viewModel.state.collectAsStateWithLifecycle()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(ds.cardColor)
            .padding(horizontal = 16.dp)
    ) {
        // Handle — 40×5 dp, white 30% opacity, centered
        Box(
            modifier = Modifier
                .padding(top = 12.dp, bottom = 20.dp)
                .width(40.dp)
                .height(5.dp)
                .background(Color.White.copy(alpha = 0.3f), RoundedCornerShape(2.5.dp))
                .align(Alignment.CenterHorizontally)
        )

        VehiclePickerSection(trip = trip, onVehicleSelected = { viewModel.selectVehicle(it) })

        HorizontalDivider(
            color = Color.White.copy(alpha = 0.1f),
            modifier = Modifier.padding(vertical = 12.dp)
        )

        PriceSummarySection(trip = trip)

        BookButton(
            trip = trip,
            state = state,
            onBook = { viewModel.startRide() },
            modifier = Modifier.padding(top = 12.dp, bottom = 32.dp)
        )
    }
}

@Composable
private fun VehiclePickerSection(trip: Trip, onVehicleSelected: (VehicleType) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            "Choose a ride",
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
            color = Color.White
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            VehicleType.values().forEach { vehicle ->
                VehicleCard(
                    vehicle = vehicle,
                    isSelected = trip.vehicle == vehicle,
                    onTap = { onVehicleSelected(vehicle) },
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun VehicleCard(
    vehicle: VehicleType,
    isSelected: Boolean,
    onTap: () -> Unit,
    modifier: Modifier = Modifier
) {
    val primary = Color(0xFF007AFF)
    val bg = if (isSelected) primary.copy(alpha = 0.15f) else Color.White.copy(alpha = 0.05f)
    val borderColor = if (isSelected) primary else Color.White.copy(alpha = 0.1f)

    Column(
        modifier = modifier
            .background(bg, RoundedCornerShape(12.dp))
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .clickable(onClick = onTap)
            .padding(vertical = 14.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Emoji icon — mirrors iOS SF Symbol intent (bicycle / car.fill / scooter)
        Text(
            vehicle.emoji,
            fontSize = 24.sp
        )
        Text(
            vehicle.title,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = if (isSelected) primary else Color.White.copy(alpha = 0.7f)
        )
        Text(
            "$${vehicle.basePrice.roundToInt()}",
            fontSize = 10.sp,
            color = Color.White.copy(alpha = 0.5f)
        )
    }
}

@Composable
private fun PriceSummarySection(trip: Trip) {
    val distanceKm = "%.1f km".format(trip.distanceMeters / 1000)
    val durationMin = "${(trip.durationSeconds / 60).roundToInt()} min"

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SummaryRow(label = "Distance", value = distanceKm)
        SummaryRow(label = "Duration", value = durationMin)
        SummaryRow(label = "Discount", value = "-$${trip.discount.roundToInt()}")

        HorizontalDivider(
            color = Color.White.copy(alpha = 0.1f),
            modifier = Modifier.padding(vertical = 4.dp)
        )

        // Total row — label in white, value in green (#34C759) matching iOS
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                "Total",
                style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.SemiBold),
                color = Color.White
            )
            Spacer(Modifier.weight(1f))
            Text(
                "$${trip.finalPrice.roundToInt()}",
                fontSize = 19.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF34C759)
            )
        }
    }
}

@Composable
private fun SummaryRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(label, fontSize = 14.sp, color = Color.White.copy(alpha = 0.6f))
        Spacer(Modifier.weight(1f))
        Text(value, fontSize = 14.sp, color = Color.White)
    }
}

@Composable
private fun BookButton(
    trip: Trip,
    state: TripState,
    onBook: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isReady = state == TripState.RouteReady

    Button(
        onClick = onBook,
        enabled = isReady,
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color(0xFF007AFF),
            disabledContainerColor = Color(0xFF007AFF).copy(alpha = 0.4f)
        ),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        Text(
            "Book ${trip.vehicle.title}",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White
        )
    }
}
