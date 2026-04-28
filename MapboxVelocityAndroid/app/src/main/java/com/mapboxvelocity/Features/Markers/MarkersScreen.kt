package com.mapboxvelocity.Features.Markers

import android.graphics.BitmapFactory
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.mapboxvelocity.Core.Design.VelocityDesignSystem
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun MarkersScreen(viewModel: MarkersViewModel) {
    val ds = VelocityDesignSystem
    val context = LocalContext.current
    val config by viewModel.config.collectAsStateWithLifecycle()
    val scope = rememberCoroutineScope()
    var showSavedBanner by remember { mutableStateOf(false) }

    val imagePicker = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let {
            val bytes = context.contentResolver.openInputStream(it)?.readBytes()
            viewModel.updateCustomImage(bytes)
        }
    }

    Box(modifier = Modifier.fillMaxSize().background(ds.backgroundColor)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
        ) {
            Spacer(Modifier.height(24.dp))

            // Marker name — mirrors iOS markerNameTextfield
            OutlinedTextField(
                value = config.label,
                onValueChange = { viewModel.updateLabel(it) },
                label = { Text("Marker Name", color = ds.textSecondary, style = VelocityDesignSystem.Typography.caption) },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ds.primaryColor,
                    unfocusedBorderColor = Color.White.copy(alpha = 0.1f),
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedContainerColor = ds.surfaceColor,
                    unfocusedContainerColor = ds.surfaceColor,
                    cursorColor = ds.primaryColor
                ),
                textStyle = VelocityDesignSystem.Typography.body
            )

            Spacer(Modifier.height(24.dp))

            // Shape buttons — mirrors iOS pinButton/dotButton/circleButton/startButton
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                MarkerShape.values().forEach { shape ->
                    ShapeButton(
                        shape = shape,
                        isSelected = config.shape == shape,
                        onClick = { viewModel.updateShape(shape) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(Modifier.height(24.dp))

            // Color dots — mirrors iOS colorButtons (white/green/pink/orange/purple/teal)
            LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                items(MarkerColor.values()) { color ->
                    val isSelected = config.color == color
                    val scale by animateFloatAsState(
                        targetValue = if (isSelected) 1.15f else 1.0f,
                        label = "colorScale"
                    )
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .scale(scale)
                            .clip(CircleShape)
                            .background(Color(color.argb))
                            .border(
                                width = if (isSelected) 3.dp else 0.dp,
                                color = if (isSelected) Color.White else Color.Transparent,
                                shape = CircleShape
                            )
                            .clickable { viewModel.updateColor(color) }
                    )
                }
            }

            Spacer(Modifier.height(24.dp))

            // Preview card — mirrors iOS previewView + previewIconView + previewNameLabel
            PreviewCard(config = config, context = context)

            Spacer(Modifier.height(24.dp))

            // Upload button — mirrors iOS uploadCustomImageButton ("Add Photo", blue tinted)
            Button(
                onClick = { imagePicker.launch("image/*") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF4b8eff).copy(alpha = 0.15f),
                    contentColor = Color(0xFF4b8eff)
                )
            ) {
                Icon(Icons.Default.AddAPhoto, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("Add Photo", style = VelocityDesignSystem.Typography.button.copy(fontSize = 15.sp))
            }

            Spacer(Modifier.height(8.dp))

            // Save button — mirrors iOS saveButton (green, filled)
            Button(
                onClick = {
                    viewModel.save()
                    showSavedBanner = true
                    scope.launch {
                        delay(2000)
                        showSavedBanner = false
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = ButtonDefaults.buttonColors(containerColor = ds.secondaryColor)
            ) {
                Icon(Icons.Default.LocationOn, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("Save Marker", style = VelocityDesignSystem.Typography.button, color = Color.White, fontWeight = FontWeight.Bold)
            }

            Spacer(Modifier.height(48.dp))
        }

        // Saved banner — mirrors iOS showSavedBanner() (blue pill, fades out after 2s)
        if (showSavedBanner) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 16.dp)
                    .background(Color(0xFF4b8eff), RoundedCornerShape(10.dp))
                    .padding(horizontal = 16.dp, vertical = 8.dp)
            ) {
                Text(
                    "  Marker saved  ",
                    color = Color.White,
                    style = VelocityDesignSystem.Typography.caption.copy(fontWeight = FontWeight.SemiBold)
                )
            }
        }
    }
}

@Composable
private fun ShapeButton(
    shape: MarkerShape,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val accentColor = Color(0xFF4b8eff)
    val bg = if (isSelected) accentColor.copy(alpha = 0.2f) else Color.White.copy(alpha = 0.04f)
    val borderColor = if (isSelected) accentColor else Color.White.copy(alpha = 0.1f)

    Column(
        modifier = modifier
            .background(bg, RoundedCornerShape(12.dp))
            .border(1.5.dp, borderColor, RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(getShapeEmoji(shape), fontSize = 18.sp)
        Text(
            shape.title,
            fontSize = 9.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isSelected) accentColor else Color(0xFF8b90a0)
        )
    }
}

private fun getShapeEmoji(shape: MarkerShape): String = when (shape) {
    MarkerShape.PIN    -> "📍"
    MarkerShape.DOT    -> "⬤"
    MarkerShape.CIRCLE -> "○"
    MarkerShape.STAR   -> "★"
}

@Composable
private fun PreviewCard(config: MarkerConfig, context: android.content.Context) {
    val ds = VelocityDesignSystem

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF1a1f2e), RoundedCornerShape(16.dp))
            .border(1.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Icon box — coloured background at 20% opacity, matches iOS previewIconView background
        Box(
            modifier = Modifier
                .size(56.dp)
                .background(
                    Color(config.color.argb).copy(alpha = 0.2f),
                    RoundedCornerShape(12.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            val customData = config.customImageData
            if (customData != null) {
                // Custom photo picked by user — decode and show
                val bitmap = remember(customData) {
                    BitmapFactory.decodeByteArray(customData, 0, customData.size)
                }
                if (bitmap != null) {
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = null,
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(8.dp))
                    )
                }
            } else {
                // Rendered shape — re-render whenever shape or color changes
                val rendered = remember(config.shape, config.color) {
                    MarkerImageRenderer.image(context, config.shape, config.color, size = 88)
                }
                Image(
                    bitmap = rendered.asImageBitmap(),
                    contentDescription = null,
                    modifier = Modifier.size(44.dp)
                )
            }
        }

        Column {
            Text(
                config.label.ifEmpty { "Secret Spot" },
                color = Color.White,
                style = VelocityDesignSystem.Typography.body.copy(fontWeight = FontWeight.SemiBold)
            )
            Text(
                "Live preview · ${config.shape.title.lowercase()} shape",
                color = ds.textSecondary,
                style = VelocityDesignSystem.Typography.caption
            )
        }
    }
}
