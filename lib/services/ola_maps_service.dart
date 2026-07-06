import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class OlaMapsService {
  static String get _apiKey => dotenv.env['OLA_MAPS_API_KEY'] ?? '';

  static Map<String, String> get _headers => {
        'X-Request-Id':
            'vasundhara-req-${DateTime.now().millisecondsSinceEpoch}',
      };

  /// Fetches autocomplete location suggestions.
  static Future<List<Map<String, dynamic>>> fetchLocationSuggestions(
    String query,
  ) async {
    if (query.trim().isEmpty) return [];

    try {
      final url =
          'https://api.olamaps.io/places/v1/autocomplete?input=${Uri.encodeComponent(query)}&api_key=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null) {
          final predictions = data['predictions'] as List;
          return predictions
              .map(
                (p) => {
                  'display_name': p['description'],
                  'lat': p['geometry']['location']['lat'],
                  'lon': p['geometry']['location']['lng'],
                },
              )
              .toList();
        }
      } else {
        debugPrint('Autocomplete API Denied: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    return [];
  }

  /// Reverse geocodes coordinates into an address.
  static Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final url =
          'https://api.olamaps.io/places/v1/reverse-geocode?latlng=$lat,$lon&api_key=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String?;
        }
      } else {
        debugPrint('Reverse Geocode API Denied: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return null;
  }

  /// Fetches routing directions between origin and destination.
  static Future<List<LatLng>?> getRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final url =
          'https://api.olamaps.io/routing/v1/directions?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&api_key=$_apiKey';
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['overview_polyline'];
          if (geometry != null) {
            return _decodePolyline(geometry as String);
          }
        }
      } else {
        debugPrint('Routing API Denied: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Routing error: $e');
    }
    return null;
  }

  /// Decodes an encoded polyline string to a List of LatLng
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
