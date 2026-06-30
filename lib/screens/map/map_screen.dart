import 'dart:convert';
import 'package:flutter/material.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  bool get isMarathi => context.watch<SettingsProvider>().isMarathi;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showNurseries = true;

  // Mock Nurseries Data
  final List<Map<String, dynamic>> _nurseries = [
    {
      'name': 'Green Leaf Nursery',
      'lat': 18.5154,
      'lon': 73.8617,
      'description': 'Wide variety of indoor and outdoor plants.',
      'phone': '+91 9876543210',
    },
    {
      'name': 'Pune Plant Center',
      'lat': 18.5294,
      'lon': 73.8467,
      'description': 'Specialists in fruit trees and local saplings.',
      'phone': '+91 8765432109',
    },
  ];

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
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
        throw Exception('API Denied: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return const Iterable<Map<String, dynamic>>.empty();
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    final loc.Location location = loc.Location();
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
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

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isMarathi
                    ? 'स्थानाची परवानगी नाकारली.'
                    : 'Location permissions are denied.',
              ),
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMarathi
                  ? 'स्थानाची परवानगी कायमची नाकारली आहे.'
                  : 'Location permissions are permanently denied.',
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isMarathi ? 'स्थान शोधत आहे...' : 'Locating...'),
        ),
      );
    }

    final position = await Geolocator.getCurrentPosition();
    _animatedMapMove(LatLng(position.latitude, position.longitude), 15.0);
  }

  Future<void> _openMapsForDirections(double lat, double lon) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMarathi ? 'नकाशा उघडू शकलो नाही.' : 'Could not open maps.',
            ),
          ),
        );
      }
    }
  }

  void _showNurseryDetails(Map<String, dynamic> nursery) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nursery['name'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nursery['description'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    nursery['phone'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openMapsForDirections(
                      nursery['lat'] as double,
                      nursery['lon'] as double,
                    );
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: Text(
                    isMarathi ? 'मार्गदर्शक मिळवा' : 'Get Directions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTreeDetails(PlantedTree tree) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          tree.speciesName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${tree.location}'),
            Text('Quantity: ${tree.quantity}'),
            const SizedBox(height: 16),
            if (tree.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: tree.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child:
                      Icon(CupertinoIcons.tree, size: 50, color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isMarathi ? 'बंद करा' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> nurseryMarkers = _nurseries.map((n) {
      return Marker(
        point: LatLng(n['lat'] as double, n['lon'] as double),
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: () => _showNurseryDetails(n),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: const Icon(Icons.storefront, color: Colors.orange, size: 28),
          ),
        ),
      );
    }).toList();

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
          _buildMapLayer(nurseryMarkers),
          _buildSearchBar(),
          _buildLocateMeFab(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMapLayer(List<Marker> nurseryMarkers) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(18.5204, 73.8567),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vasundhara.treeapp',
        ),
        if (_showNurseries)
          MarkerLayer(
            markers: nurseryMarkers,
          )
        else
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final List<Marker> treeMarkers = userProvider.plantedTrees
                  .where((t) => t.latitude != null && t.longitude != null)
                  .map(
                    (tree) => Marker(
                      point: LatLng(tree.latitude!, tree.longitude!),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showTreeDetails(tree),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.leaf_arrow_circlepath,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList();

              return MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  markers: treeMarkers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
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
            _animatedMapMove(LatLng(lat, lon), 15.0);
            FocusScope.of(context).unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
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
                          child: CircularProgressIndicator(strokeWidth: 2),
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
