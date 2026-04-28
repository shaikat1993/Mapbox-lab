package com.mapboxvelocity.Services

import com.mapbox.geojson.Point
import com.mapboxvelocity.BuildConfig
import com.mapboxvelocity.Core.Protocols.DirectionsServiceProtocol
import com.mapboxvelocity.Core.Protocols.RouteResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class DirectionsService(
    private val httpClient: OkHttpClient
) : DirectionsServiceProtocol {

    private val accessToken = BuildConfig.MAPBOX_ACCESS_TOKEN

    override suspend fun fetchRoute(from: Point, to: Point): Result<RouteResult> = withContext(Dispatchers.IO) {
        val url = "https://api.mapbox.com/directions/v5/mapbox/driving/" +
                "${from.longitude()},${from.latitude()};" +
                "${to.longitude()},${to.latitude()}" +
                "?access_token=$accessToken&geometries=geojson&overview=full&steps=false"

        val response = runCatching {
            httpClient.newCall(Request.Builder().url(url).build()).execute()
        }.getOrElse { return@withContext Result.failure(it) }

        val body = response.body?.string()
            ?: return@withContext Result.failure(Exception("Empty response"))

        runCatching {
            val json = JSONObject(body)
            val route = json.getJSONArray("routes").getJSONObject(0)
            val distance = route.getDouble("distance")
            val duration = route.getDouble("duration")
            val coordsArray = route.getJSONObject("geometry").getJSONArray("coordinates")

            val coordinates = buildList {
                for (i in 0 until coordsArray.length()) {
                    val c = coordsArray.getJSONArray(i)
                    add(Point.fromLngLat(c.getDouble(0), c.getDouble(1)))
                }
            }

            RouteResult(
                coordinates = coordinates,
                distanceMeters = distance,
                durationSeconds = duration
            )
        }
    }
}
