package com.mapboxvelocity.Services

import com.mapbox.geojson.Point
import com.mapboxvelocity.BuildConfig
import com.mapboxvelocity.Core.Models.GeocodingResult
import com.mapboxvelocity.Core.Protocols.GeocodingServiceProtocol
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.net.URLEncoder
import java.util.Locale

class GeocodingService(
    private val httpClient: OkHttpClient
) : GeocodingServiceProtocol {

    private val accessToken = BuildConfig.MAPBOX_ACCESS_TOKEN

    // ISO 3166-1 alpha-2 from device locale — mirrors iOS Locale.current.region?.identifier
    // e.g. "BD" in Bangladesh, "FI" in Finland, "US" fallback
    private val countryCode: String
        get() = Locale.getDefault().country.ifEmpty { "US" }

    override suspend fun search(query: String): List<GeocodingResult> = withContext(Dispatchers.IO) {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) return@withContext emptyList()

        // Full percent-encoding — mirrors iOS addingPercentEncoding(.urlPathAllowed)
        val encoded = URLEncoder.encode(trimmed, "UTF-8")
            .replace("+", "%20")   // URLEncoder encodes spaces as +; Mapbox needs %20

        val url = "https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json" +
                "?access_token=$accessToken&limit=5&language=en&country=$countryCode"

        val response = runCatching {
            httpClient.newCall(Request.Builder().url(url).build()).execute()
        }.getOrNull() ?: return@withContext emptyList()

        if (!response.isSuccessful) return@withContext emptyList()

        val body = response.body?.string() ?: return@withContext emptyList()
        val features = runCatching { JSONObject(body).optJSONArray("features") }
            .getOrNull() ?: return@withContext emptyList()

        buildList {
            for (i in 0 until features.length()) {
                parseFeature(features.getJSONObject(i))?.let { add(it) }
            }
        }
    }

    override suspend fun reverseGeocode(point: Point): GeocodingResult? = withContext(Dispatchers.IO) {
        // No country filter on reverse geocode — matches iOS implementation
        val url = "https://api.mapbox.com/geocoding/v5/mapbox.places/" +
                "${point.longitude()},${point.latitude()}.json" +
                "?access_token=$accessToken&limit=1&language=en"

        val response = runCatching {
            httpClient.newCall(Request.Builder().url(url).build()).execute()
        }.getOrNull() ?: return@withContext null

        if (!response.isSuccessful) return@withContext null

        val body = response.body?.string() ?: return@withContext null
        val features = runCatching { JSONObject(body).optJSONArray("features") }
            .getOrNull() ?: return@withContext null
        if (features.length() == 0) return@withContext null

        parseFeature(features.getJSONObject(0))
    }

    private fun parseFeature(feature: JSONObject): GeocodingResult? {
        val coords = feature.optJSONObject("geometry")
            ?.optJSONArray("coordinates") ?: return null
        if (coords.length() < 2) return null

        val point = Point.fromLngLat(coords.getDouble(0), coords.getDouble(1))
        val address = formatAddress(feature)
        return GeocodingResult(point = point, address = address)
    }

    // Builds "Street Name 12, City" — exact mirror of iOS GeocodingService.formatAddress
    private fun formatAddress(feature: JSONObject): String {
        val streetName   = feature.optString("text", "")
        val streetNumber = feature.optString("address", "")
        val street = if (streetNumber.isEmpty()) streetName else "$streetName $streetNumber"

        // context array: neighbourhood → postcode → place (city) → region → country
        var city = ""
        val context = feature.optJSONArray("context")
        if (context != null) {
            for (i in 0 until context.length()) {
                val entry = context.getJSONObject(i)
                if (entry.optString("id").startsWith("place.")) {
                    city = entry.optString("text", "")
                    break
                }
            }
        }

        // Fallback — take first two comma-separated parts of place_name
        // strips postcode/region/country, mirrors iOS .prefix(2).joined
        val placeName = feature.optString("place_name", "")
        val fallback = placeName.split(",").take(2).joinToString(",").trim()

        return when {
            street.isNotEmpty() && city.isNotEmpty() -> "$street, $city"
            street.isNotEmpty() -> street
            else -> fallback
        }
    }
}
