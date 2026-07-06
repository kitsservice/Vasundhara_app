import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_marker_service.dart';
import '../../models/tree_marker_model.dart';
import '../../models/nursery_marker_model.dart';
import '../../core/constants/api_keys.dart';

class OlaMapScreen extends StatefulWidget {
  const OlaMapScreen({super.key});

  @override
  State<OlaMapScreen> createState() => _OlaMapScreenState();
}

class _OlaMapScreenState extends State<OlaMapScreen> {
  bool get isMarathi => context.read<SettingsProvider>().isMarathi;
  MethodChannel? _channel;
  bool _mapReady = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showNurseries = true;

  final FirestoreMarkerService _firestoreService = FirestoreMarkerService();
  List<TreeMarkerModel> _trees = [];
  List<NurseryMarkerModel> _nurseries = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final trees = await _firestoreService.getPlantedTrees();
      final nurseries = await _firestoreService.getNurseries();
      if (mounted) {
        setState(() {
          _trees = trees;
          _nurseries = nurseries;
        });
        _addMarkersToMap();
      }
    } catch (e) {
      debugPrint('Error fetching map data: $e');
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('ola_map_view_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
    
    _channel?.invokeMethod('initializeMap', {
      'apiKey': ApiKeys.olaMapsApiKey,
    });
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onMapReady':
        setState(() {
          _mapReady = true;
        });
        debugPrint('Ola Map natively loaded and ready!');
        _addMarkersToMap();
        break;
      case 'onMapError':
        debugPrint('Ola Map error: ${call.arguments}');
        break;
      default:
        break;
    }
  }

  void _addMarkersToMap() {
    if (!_mapReady || _channel == null) return;
    
    if (_showNurseries) {
      for (var nursery in _nurseries) {
        _channel!.invokeMethod('addMarker', {
          'id': 'nursery_${nursery.id}',
          'lat': nursery.latitude,
          'lng': nursery.longitude,
          'type': 'nursery',
        });
      }
    } else {
      for (var tree in _trees) {
        _channel!.invokeMethod('addMarker', {
          'id': 'tree_${tree.id}',
          'lat': tree.latitude,
          'lng': tree.longitude,
          'type': 'tree',
        });
      }
    }
  }

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
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=in&addressdetails=1',
        ),
        headers: {
          'User-Agent': 'in.vasundhara.app',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      return const Iterable<Map<String, dynamic>>.empty();
    } catch (e) {
      debugPrint('Search error: $e');
      return const Iterable<Map<String, dynamic>>.empty();
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _locateUser() async {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    // Assuming native SDK has a moveTo method, we can add it later.
    // For now, we will just fetch location to ensure permissions are good.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? 'वसुंधरा नकाशा' : 'Global Tree Map'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showNurseries = !_showNurseries;
              });
              _addMarkersToMap();
            },
            icon: Icon(
              _showNurseries ? Icons.storefront : CupertinoIcons.tree,
              color: AppColors.primary,
            ),
            tooltip: _showNurseries ? 'Showing Nurseries' : 'Showing Trees',
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().toggleLanguage();
            },
            child: Text(
              isMarathi ? 'EN' : 'MR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AndroidView(
              viewType: 'ola_map_view',
              onPlatformViewCreated: _onPlatformViewCreated,
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          if (!_mapReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
          _buildSearchBar(),
          _buildLocateMeFab(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
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
            // _animatedMapMove(LatLng(lat, lon), 15.0);
            FocusScope.of(context).unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onFieldSubmitted(),
              decoration: InputDecoration(
                hintText: isMarathi
                    ? 'शहर किंवा ठिकाण शोधा...'
                    : 'Search for an area or city...',
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocateMeFab() {
    return Positioned(
      bottom: 120,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'locate_me_fab',
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        onPressed: _locateUser,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMarathi ? 'नकाशा सूची' : 'Map Legend',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.leaf_arrow_circlepath,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(isMarathi ? 'लावलेली झाडे' : 'Planted Trees'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(isMarathi ? 'रोपवाटिका' : 'Nurseries'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
