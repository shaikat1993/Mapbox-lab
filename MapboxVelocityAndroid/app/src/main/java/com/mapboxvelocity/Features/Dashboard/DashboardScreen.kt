package com.mapboxvelocity.Features.Dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Image
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mapboxvelocity.Core.Design.VelocityDesignSystem

@Composable
fun DashboardScreen(
    onNavigate: (CardDestination) -> Unit,
    viewModel: DashboardViewModel = viewModel()
) {
    val cards by viewModel.cards.collectAsStateWithLifecycle()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF121212)),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(cards) { card ->
            DashboardCard(card = card, onClick = { onNavigate(card.destination) })
        }
    }
}

@Composable
private fun DashboardCard(card: DashboardCardModel, onClick: () -> Unit) {
    val ds = VelocityDesignSystem
    val context = LocalContext.current

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(180.dp)
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick)
    ) {
        // Background image — full bleed like iOS backgroundImageView
        val bgResId = context.resources.getIdentifier(card.backgroundImage, "drawable", context.packageName)
        if (bgResId != 0) {
            Image(
                painter = painterResource(id = bgResId),
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        } else {
            Box(modifier = Modifier.fillMaxSize().background(ds.surfaceColor))
        }

        // Dark overlay — same 0.45 alpha as before
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.45f))
        )

        // Icon + title + subtitle pinned to bottom-left — mirrors iOS CardView layout
        Row(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val iconResId = context.resources.getIdentifier(card.icon, "drawable", context.packageName)
            if (iconResId != 0) {
                Image(
                    painter = painterResource(id = iconResId),
                    contentDescription = null,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(RoundedCornerShape(8.dp))
                )
            }

            Column {
                Text(
                    card.title,
                    style = VelocityDesignSystem.Typography.body.copy(fontWeight = FontWeight.Bold),
                    color = Color.White
                )
                Text(
                    card.subtitle,
                    style = VelocityDesignSystem.Typography.caption,
                    color = Color.White.copy(alpha = 0.7f),
                    maxLines = 2
                )
            }
        }
    }
}
