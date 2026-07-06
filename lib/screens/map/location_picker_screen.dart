import 'dart:convert';
import '../../core/constants/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  bool _isLoadingAddress = false;
  bool _isSearching = false;

  Future<Iterable<Map<String, dynamic>>> _fetchLocationSuggestions(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return const Iterable<Map<String, dynamic>>.empty();
    }

    setState(() => _isSearching = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=in&addressdetails=1&email=vasundhara.app@example.com',
        ),
        headers: {
          'User-Agent': 'in.vasundhara.app',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API Denied');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      return const Iterable<Map<String, dynamic>>.empty();
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation == null) {
      _locateUser();
    }
  }

  Future<void> _locateUser() async {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          final isMarathi = context.read<SettingsProvider>().isMarathi;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isMarathi
                    ? 'कृपया तुमचे GPS चालू करा आणि पुन्हा प्रयत्न करा.'
                    : 'Please enable your GPS and try again.',
              ),
            ),
          );
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      _mapController.move(LatLng(position.latitude, position.longitude), 16.0);
    }
  }

  Future<void> _confirmLocation() async {
    setState(() => _isLoadingAddress = true);
    try {
      final center = _mapController.camera.center;
      final lat = center.latitude;
      final lon = center.longitude;

      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
        ),
        headers: {
          'User-Agent': 'in.vasundhara.app',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String? ?? 'Unknown Location';

        if (mounted) {
          Navigator.pop(context, {
            'address': address,
            'lat': lat,
            'lon': lon,
          });
        }
      } else {
        throw Exception('API error');
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      if (mounted) {
        // Fallback if API fails
        final center = _mapController.camera.center;
        Navigator.pop(context, {
          'address':
              'Location (${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)})',
          'lat': center.latitude,
          'lon': center.longitude,
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? 'ठिकाण निवडा' : 'Pick Location'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  widget.initialLocation ?? const LatLng(18.5204, 73.8567),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.olamaps.io/tiles/vector/v1/styles/default-light-standard/xyz/{z}/{x}/{y}.png?api_key=${ApiKeys.olaMapsApiKey}',
                userAgentPackageName: 'com.vasundhara.treeapp',
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  return _fetchLocationSuggestions(textEditingValue.text);
                },
                displayStringForOption: (Map<String, dynamic> option) {
                  return option['display_name'] as String;
                },
                onSelected: (Map<String, dynamic> selection) {
                  final lat = double.parse(selection['lat'].toString());
                  final lon = double.parse(selection['lon'].toString());
                  final newPosition = LatLng(lat, lon);
                  _mapController.move(newPosition, 15.0);
                  FocusScope.of(context).unfocus();
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                    decoration: InputDecoration(
                      hintText: isMarathi
                          ? 'शहर किंवा ठिकाण शोधा...'
                          : 'Search for an area or city...',
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: Colors.white,
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                option['display_name'] as String,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Center Pin Marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 50,
                  color: AppColors.primary,
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Locate Me Button
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'locate_me_picker_fab',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _locateUser,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isLoadingAddress ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              child: _isLoadingAddress
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isMarathi ? 'येथे निश्चित करा' : 'Confirm Location Here',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
