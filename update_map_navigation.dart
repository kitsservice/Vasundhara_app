// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  // 1. Update OlaMapPlatformView.kt
  final ktFile = File('android/app/src/main/kotlin/com/kits/vasundhara/OlaMapPlatformView.kt');
  var ktContent = ktFile.readAsStringSync();
  const ktTarget = 'else -> result.notImplemented()';
  const ktReplacement = '''            "moveToLocation" -> {
                val lat = call.argument<Double>("lat") ?: return
                val lng = call.argument<Double>("lng") ?: return
                val zoom = call.argument<Double>("zoom") ?: 15.0
                
                try {
                    val mapClass = olaMap!!.javaClass
                    val latLngClass = Class.forName("com.ola.mapsdk.model.OlaLatLng")
                    val latLngConstructor = latLngClass.getConstructor(Double::class.java, Double::class.java)
                    val latLng = latLngConstructor.newInstance(lat, lng)
                    
                    val factoryClass = Class.forName("com.ola.mapsdk.model.OlaCameraUpdateFactory")
                    val newLatLngZoomMethod = factoryClass.getMethod("newLatLngZoom", latLngClass, Float::class.java)
                    val cameraUpdate = newLatLngZoomMethod.invoke(null, latLng, zoom.toFloat())
                    
                    try {
                        val animateCamera = mapClass.getMethod("animateCamera", Class.forName("com.ola.mapsdk.model.OlaCameraUpdate"))
                        animateCamera.invoke(olaMap, cameraUpdate)
                    } catch (e: Exception) {
                        val moveCamera = mapClass.getMethod("moveCamera", Class.forName("com.ola.mapsdk.model.OlaCameraUpdate"))
                        moveCamera.invoke(olaMap, cameraUpdate)
                    }
                    result.success(null)
                } catch (e: Exception) {
                    try {
                        val mapClass = olaMap!!.javaClass
                        val latLngClass = Class.forName("org.maplibre.android.geometry.LatLng")
                        val latLngConstructor = latLngClass.getConstructor(Double::class.java, Double::class.java)
                        val latLng = latLngConstructor.newInstance(lat, lng)
                        
                        val factoryClass = Class.forName("org.maplibre.android.camera.CameraUpdateFactory")
                        val newLatLngZoomMethod = factoryClass.getMethod("newLatLngZoom", latLngClass, Double::class.java)
                        val cameraUpdate = newLatLngZoomMethod.invoke(null, latLng, zoom)
                        
                        try {
                            val animateCamera = mapClass.getMethod("animateCamera", Class.forName("org.maplibre.android.camera.CameraUpdate"))
                            animateCamera.invoke(olaMap, cameraUpdate)
                        } catch (e2: Exception) {
                            val moveCamera = mapClass.getMethod("moveCamera", Class.forName("org.maplibre.android.camera.CameraUpdate"))
                            moveCamera.invoke(olaMap, cameraUpdate)
                        }
                        result.success(null)
                    } catch (e3: Exception) {
                        Log.e(TAG, "Reflection failed to move camera", e3)
                        result.error("REFLECTION_ERROR", e3.message, null)
                    }
                }
            }
            else -> result.notImplemented()''';
  if (!ktContent.contains('moveToLocation')) {
    ktContent = ktContent.replaceFirst(ktTarget, ktReplacement);
    ktFile.writeAsStringSync(ktContent);
    print('Updated OlaMapPlatformView.kt');
  }

  // 2. Update ola_map_screen.dart
  final mapFile = File('lib/screens/ola_map_screen.dart');
  var mapContent = mapFile.readAsStringSync();
  const mapTarget1 = 'class OlaMapScreen extends StatefulWidget {\n  const OlaMapScreen({super.key});';
  const mapReplacement1 = '''class OlaMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool showBackButton;

  const OlaMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.showBackButton = false,
  });''';
  
  const mapTarget2 = '''      case 'onMapReady':
        setState(() {
          _mapReady = true;
        });
        debugPrint('Ola Map natively loaded and ready!');
        _addMarkersToMap();
        break;''';
  const mapReplacement2 = '''      case 'onMapReady':
        setState(() {
          _mapReady = true;
        });
        debugPrint('Ola Map natively loaded and ready!');
        _addMarkersToMap();
        
        if (widget.initialLat != null && widget.initialLng != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _channel?.invokeMethod('moveToLocation', {
              'lat': widget.initialLat,
              'lng': widget.initialLng,
              'zoom': 18.0,
            });
          });
        }
        break;''';
        
  const mapTarget3 = 'Widget build(BuildContext context) {\n    return Scaffold(';
  const mapReplacement3 = '''Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.showBackButton ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ) : null,''';
  
  if (!mapContent.contains('initialLat')) {
    mapContent = mapContent.replaceFirst(mapTarget1, mapReplacement1);
    mapContent = mapContent.replaceFirst(mapTarget2, mapReplacement2);
    mapContent = mapContent.replaceFirst(mapTarget3, mapReplacement3);
    mapFile.writeAsStringSync(mapContent);
    print('Updated ola_map_screen.dart');
  }

  // 3. Update my_forest_screen.dart
  final forestFile = File('lib/screens/gamification/my_forest_screen.dart');
  var forestContent = forestFile.readAsStringSync();
  const forestTarget1 = "import 'package:google_fonts/google_fonts.dart';";
  const forestReplacement1 = "import 'package:google_fonts/google_fonts.dart';\nimport '../ola_map_screen.dart';";
  
  const forestTarget2 = '''          onTap: () {
            // Future feature: View Tree Details
          },''';
  const forestReplacement2 = '''          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OlaMapScreen(
                  initialLat: tree.latitude,
                  initialLng: tree.longitude,
                  showBackButton: true,
                ),
              ),
            );
          },''';
          
  if (!forestContent.contains('OlaMapScreen(')) {
    forestContent = forestContent.replaceFirst(forestTarget1, forestReplacement1);
    forestContent = forestContent.replaceFirst(forestTarget2, forestReplacement2);
    forestFile.writeAsStringSync(forestContent);
    print('Updated my_forest_screen.dart');
  }
}
