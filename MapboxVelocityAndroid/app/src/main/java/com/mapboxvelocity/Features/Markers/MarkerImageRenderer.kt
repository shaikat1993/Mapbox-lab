package com.mapboxvelocity.Features.Markers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import androidx.core.content.ContextCompat
import com.mapboxvelocity.R
import kotlin.math.cos
import kotlin.math.sin

// Mirrors iOS MarkerImageRenderer exactly — same shapes, same drawing logic
object MarkerImageRenderer {

    fun image(context: Context, shape: MarkerShape, color: MarkerColor, size: Int = 88): Bitmap {
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        return when (shape) {
            MarkerShape.PIN    -> drawPin(context, canvas, bmp, color.argb, size)
            MarkerShape.CIRCLE -> drawCircle(canvas, bmp, color.argb, size)
            MarkerShape.DOT    -> drawDot(canvas, bmp, color.argb, size)
            MarkerShape.STAR   -> drawStar(canvas, bmp, color.argb, size)
        }
    }

    private fun drawPin(context: Context, canvas: Canvas, bmp: Bitmap, color: Int, size: Int): Bitmap {
        // Try pin drawable asset first (mirrors iOS UIImage(named: "pin"))
        ContextCompat.getDrawable(context, R.drawable.pin)?.let { drawable ->
            drawable.setBounds(0, 0, size, size)
            val paint = Paint().apply { colorFilter = PorterDuffColorFilter(color, PorterDuff.Mode.SRC_IN) }
            canvas.saveLayer(null, paint)
            drawable.draw(canvas)
            canvas.restore()
            return bmp
        }
        // Fallback: Bezier teardrop — mirrors iOS drawPin(in:rect:color:)
        val cx = size / 2f
        val r = size * 0.32f
        val cy = size * 0.14f + r + 4f
        val tipY = size - 4f
        val angle = (Math.PI / 6).toFloat()
        val leftX  = cx - r * sin(angle)
        val leftY  = cy + r * cos(angle)
        val rightX = cx + r * sin(angle)
        val rightY = cy + r * cos(angle)

        val path = Path().apply {
            moveTo(leftX, leftY)
            lineTo(cx, tipY)
            lineTo(rightX, rightY)
            arcTo(cx - r, cy - r, cx + r, cy + r,
                90f + Math.toDegrees(angle.toDouble()).toFloat(),
                360f - 2 * Math.toDegrees(angle.toDouble()).toFloat(),
                false)
            close()
        }
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color; style = Paint.Style.FILL }
        canvas.drawPath(path, paint)

        // White inner dot
        val dotR = r * 0.38f
        paint.color = android.graphics.Color.argb(217, 255, 255, 255)
        canvas.drawCircle(cx, cy, dotR, paint)
        return bmp
    }

    private fun drawCircle(canvas: Canvas, bmp: Bitmap, color: Int, size: Int): Bitmap {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color; style = Paint.Style.FILL }
        val cx = size / 2f
        canvas.drawCircle(cx, cx, cx - 4f, paint)
        paint.color = android.graphics.Color.argb(217, 255, 255, 255)
        canvas.drawCircle(cx, cx, (cx - 4f) * 0.35f, paint)
        return bmp
    }

    private fun drawDot(canvas: Canvas, bmp: Bitmap, color: Int, size: Int): Bitmap {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color; style = Paint.Style.FILL }
        val cx = size / 2f
        canvas.drawCircle(cx, cx, cx - 12f, paint)
        return bmp
    }

    private fun drawStar(canvas: Canvas, bmp: Bitmap, color: Int, size: Int): Bitmap {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color; style = Paint.Style.FILL }
        val cx = size / 2f
        val cy = size / 2f
        val outerR = cx - 4f
        val innerR = outerR * 0.4f
        val points = 5
        val path = Path()
        for (i in 0 until points * 2) {
            val a = i * Math.PI / points - Math.PI / 2
            val r = if (i % 2 == 0) outerR else innerR
            val x = cx + (r * cos(a)).toFloat()
            val y = cy + (r * sin(a)).toFloat()
            if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }
        path.close()
        canvas.drawPath(path, paint)
        return bmp
    }
}
