package com.kits.vasundhara

import android.content.Context
import android.util.Log
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import com.ola.mapsdk.view.OlaMapView
import com.ola.mapsdk.view.OlaMap
import com.ola.mapsdk.interfaces.OlaMapCallback
import org.maplibre.android.MapLibre

class OlaMapPlatformView(
    private val context: Context,
    private val viewId: Int,
    private val messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler, OlaMapCallback {

    companion object {
        private const val TAG = "OlaMapPlatformView"
    }

    private val mapView: OlaMapView
    private var olaMap: OlaMap? = null
    private val methodChannel: MethodChannel = MethodChannel(messenger, "ola_map_view_$viewId")

    init {
        // MapLibre initialization might be required before OlaMapView is instantiated
        MapLibre.getInstance(context)
        
        mapView = OlaMapView(context)
        methodChannel.setMethodCallHandler(this)
        
        // Force lifecycle start to ensure map renders
        mapView.onStart()
        mapView.onResume()
        
        mapView.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {
                mapView.onStart()
                mapView.onResume()
            }
            override fun onViewDetachedFromWindow(v: View) {
                mapView.onPause()
                mapView.onStop()
            }
        })
    }

    override fun getView(): View = mapView

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        mapView.onPause()
        mapView.onStop()
        mapView.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initializeMap" -> {
                val apiKey = call.argument<String>("apiKey") ?: ""
                try {
                    mapView.getMap(apiKey, this)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to initialize map", e)
                    result.error("INIT_ERROR", e.message, null)
                }
            }
            "addMarker" -> {
                val id = call.argument<String>("id") ?: return
                val lat = call.argument<Double>("lat") ?: return
                val lng = call.argument<Double>("lng") ?: return
                val type = call.argument<String>("type") ?: "tree"
                
                if (olaMap == null) {
                    result.error("MAP_NOT_READY", "Map is not initialized yet.", null)
                    return
                }

                try {
                    val iconRes = if (type == "nursery") R.drawable.ic_nursery_logo else R.drawable.ic_tree_logo
                    
                    val bitmap = getBitmapFromVectorDrawable(context, iconRes)
                    
                    val markerOptions = com.ola.mapsdk.model.OlaMarkerOptions.Builder()
                        .setMarkerId(id)
                        .setPosition(com.ola.mapsdk.model.OlaLatLng(lat, lng))
                        .setIconBitmap(bitmap)
                        .setIsIconClickable(true)
                        .build()
                        
                    olaMap?.addMarker(markerOptions)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to add marker", e)
                    result.error("MARKER_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getBitmapFromVectorDrawable(context: Context, drawableId: Int): android.graphics.Bitmap? {
        val drawable = androidx.core.content.ContextCompat.getDrawable(context, drawableId) ?: return null
        val bitmap = android.graphics.Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            android.graphics.Bitmap.Config.ARGB_8888
        )
        val canvas = android.graphics.Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    override fun onMapReady(map: OlaMap) {
        olaMap = map
        methodChannel.invokeMethod("onMapReady", null)
    }

    override fun onMapError(error: String) {
        methodChannel.invokeMethod("onMapError", error)
    }
}
