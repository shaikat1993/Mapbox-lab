package com.mapboxvelocity.Features.Settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.mapboxvelocity.Core.Design.VelocityDesignSystem

@Composable
fun SettingsScreen(viewModel: SettingsViewModel) {
    val selectedStyle by viewModel.selectedStyle.collectAsStateWithLifecycle()
    val overlays by viewModel.overlays.collectAsStateWithLifecycle()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0d1117)),
        contentPadding = PaddingValues(bottom = 32.dp)
    ) {
        item { SectionHeader("MAP STYLE") }

        item {
            StyleSectionCell(
                styles = MapStyle.values().toList(),
                selected = selectedStyle,
                onStyleSelected = { viewModel.selectStyle(it) }
            )
        }

        item { SectionHeader("OVERLAYS") }

        itemsIndexed(overlays) { index, overlay ->
            OverlayCell(
                overlay = overlay,
                isLast = index == overlays.lastIndex,
                onToggle = { viewModel.toggleOverlay(overlay.id, it) }
            )
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(36.dp)
            .padding(horizontal = 16.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Text(
            title,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color(0xFF8b90a0)
        )
    }
}

// Mirrors iOS StyleSectionCell — 2-column grid, Wolt spans full width
@Composable
private fun StyleSectionCell(
    styles: List<MapStyle>,
    selected: MapStyle,
    onStyleSelected: (MapStyle) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Split into rows: pair up non-full-width styles, full-width styles alone
        val rows = mutableListOf<List<MapStyle>>()
        val buffer = mutableListOf<MapStyle>()
        for (style in styles) {
            if (style.isFullWidth) {
                if (buffer.isNotEmpty()) { rows.add(buffer.toList()); buffer.clear() }
                rows.add(listOf(style))
            } else {
                buffer.add(style)
                if (buffer.size == 2) { rows.add(buffer.toList()); buffer.clear() }
            }
        }
        if (buffer.isNotEmpty()) rows.add(buffer.toList())

        rows.forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                row.forEach { style ->
                    MapStyleCard(
                        style = style,
                        isSelected = style == selected,
                        onClick = { onStyleSelected(style) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        Spacer(Modifier.height(4.dp))
    }
}

// Mirrors iOS MapStyleCell — tall vertical card with preview icon, badges, radio
@Composable
private fun MapStyleCard(
    style: MapStyle,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val accent = accentColor(style)
    val cardBg = if (isSelected) selectedCardBg(style) else Color.White.copy(alpha = 0.03f)
    val borderColor = if (isSelected) accent.copy(alpha = 0.55f) else Color.Transparent

    Column(
        modifier = modifier
            .height(160.dp)
            .background(cardBg, RoundedCornerShape(16.dp))
            .border(
                width = if (isSelected) 1.5.dp else 0.dp,
                color = borderColor,
                shape = RoundedCornerShape(16.dp)
            )
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick)
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        // Top row: preview icon box + ACTIVE badge
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // SF Symbol equivalent preview box — icon emoji at 28sp, accent bg 8%
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .background(accent.copy(alpha = 0.08f), RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(previewEmoji(style), fontSize = 28.sp)
            }

            Spacer(Modifier.weight(1f))

            // ACTIVE badge — mirrors iOS activeBadge
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .background(accent, RoundedCornerShape(6.dp))
                        .padding(horizontal = 6.dp, vertical = 3.dp)
                ) {
                    Text(
                        "ACTIVE",
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Black,
                        color = Color(0xFF001a41)
                    )
                }
            }
        }

        Spacer(Modifier.weight(1f))

        // Title + radio row
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                style.title,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = if (isSelected) accent else Color.White
            )
            Spacer(Modifier.weight(1f))
            // Radio button — mirrors iOS radioButton (largecircle.fill.circle / circle)
            Text(
                if (isSelected) "◉" else "○",
                fontSize = 16.sp,
                color = if (isSelected) accent else Color.White.copy(alpha = 0.3f)
            )
        }

        // Subtitle
        Text(
            style.subtitle,
            fontSize = 10.sp,
            color = Color(0xFF8b90a0),
            maxLines = 2
        )

        // INSPIRED badge for Wolt — mirrors iOS inspiredBadge
        if (style.isInspired) {
            Box(
                modifier = Modifier
                    .background(accent.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                    .border(1.dp, accent.copy(alpha = 0.4f), RoundedCornerShape(4.dp))
                    .padding(horizontal = 5.dp, vertical = 2.dp)
            ) {
                Text(
                    "INSPIRED",
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Black,
                    color = accent
                )
            }
        }
    }
}

// Mirrors iOS OverlayCell
@Composable
private fun OverlayCell(
    overlay: TechnicalOverlay,
    isLast: Boolean,
    onToggle: (Boolean) -> Unit
) {
    val ds = VelocityDesignSystem

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White.copy(alpha = 0.06f))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(83.dp)
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Icon box — mirrors iOS iconImageView (blue tint, rounded, 6% white bg)
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(Color.White.copy(alpha = 0.06f), RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(overlayEmoji(overlay.id), fontSize = 18.sp)
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    overlay.title,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
                Text(
                    overlay.subtitle,
                    fontSize = 10.sp,
                    color = Color(0xFF8b90a0)
                )
            }

            Switch(
                checked = overlay.isEnabled,
                onCheckedChange = onToggle,
                colors = SwitchDefaults.colors(
                    checkedThumbColor = Color.White,
                    checkedTrackColor = Color(0xFF06300b),
                    uncheckedThumbColor = Color.White,
                    uncheckedTrackColor = Color.White.copy(alpha = 0.2f)
                )
            )
        }

        if (!isLast) {
            HorizontalDivider(
                color = Color.White.copy(alpha = 0.06f),
                modifier = Modifier.padding(start = 72.dp)
            )
        }
    }
}

// Per-style accent colors — exact match to iOS accentColor
private fun accentColor(style: MapStyle): Color = when (style) {
    MapStyle.STANDARD  -> Color(0xFFadb5bd)
    MapStyle.DARK      -> Color(0xFFadc6ff)
    MapStyle.SATELLITE -> Color(0xFF53e16f)
    MapStyle.HEATMAP   -> Color(0xFFf4a261)
    MapStyle.WOLT      -> Color(0xFF009de0)
}

// Per-style selected card backgrounds — exact match to iOS selectedCardBackground
private fun selectedCardBg(style: MapStyle): Color = when (style) {
    MapStyle.STANDARD  -> Color(0xFFe8e8e8).copy(alpha = 0.12f)
    MapStyle.DARK      -> Color(0xFFadc6ff).copy(alpha = 0.08f)
    MapStyle.SATELLITE -> Color(0xFF53e16f).copy(alpha = 0.08f)
    MapStyle.HEATMAP   -> Color(0xFFf4a261).copy(alpha = 0.10f)
    MapStyle.WOLT      -> Color(0xFFf5efe6).copy(alpha = 0.10f)
}

// Preview icon emojis — mirrors iOS previewImage SF Symbols
private fun previewEmoji(style: MapStyle): String = when (style) {
    MapStyle.STANDARD  -> "🗺️"
    MapStyle.DARK      -> "🌙"
    MapStyle.SATELLITE -> "🌍"
    MapStyle.HEATMAP   -> "🔥"
    MapStyle.WOLT      -> "🍴"
}

private fun overlayEmoji(id: String): String = when (id) {
    "buildings" -> "🏢"
    "traffic"   -> "🚗"
    else        -> "📍"
}
