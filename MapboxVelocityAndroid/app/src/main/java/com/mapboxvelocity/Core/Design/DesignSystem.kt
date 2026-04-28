package com.mapboxvelocity.Core.Design

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

interface DesignSystemProviding {
    val primaryColor: Color
    val secondaryColor: Color
    val tertiaryColor: Color
    val backgroundColor: Color
    val surfaceColor: Color
    val surface2Color: Color
    val textPrimary: Color
    val textSecondary: Color
    val textTertiary: Color
}

object VelocityDesignSystem : DesignSystemProviding {
    override val primaryColor    = Color(0xFF007AFF)
    override val secondaryColor  = Color(0xFF34C759)
    override val tertiaryColor   = Color(0xFFFF9500)
    override val backgroundColor = Color(0xFF121212)
    override val surfaceColor    = Color(0xFF1C1C1E)
    override val surface2Color   = Color(0xFF2C2C2E)
    override val textPrimary     = Color(0xFFFFFFFF)
    override val textSecondary   = Color(0xFF8E8E93)
    override val textTertiary    = Color(0xFF636366)

    // Card surface used in map search & bottom sheet
    val cardColor = Color(0xFF1a1f2e)

    object Spacing {
        val xs: Dp = 4.dp
        val sm: Dp = 8.dp
        val md: Dp = 16.dp
        val lg: Dp = 24.dp
        val xl: Dp = 32.dp
        val xxl: Dp = 48.dp
    }

    object Radius {
        val sm: Dp = 8.dp
        val md: Dp = 12.dp
        val lg: Dp = 16.dp
        val xl: Dp = 24.dp
    }

    object Typography {
        val headline = TextStyle(fontSize = 28.sp, fontWeight = FontWeight.Bold)
        val title    = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.SemiBold)
        val body     = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.Normal)
        val caption  = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Normal)
        val button   = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
    }
}
