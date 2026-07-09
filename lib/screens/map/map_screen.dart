import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_marker_service.dart';
import '../../models/tree_marker_model.dart';
import '../../models/nursery_marker_model.dart';
class MapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  bool get isMarathi => context.locale.languageCode == 'mr';
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showNurseries = true;

  final FirestoreMarkerService _firestoreService = FirestoreMarkerService();
  List<TreeMarkerModel> _trees = [];
  List<NurseryMarkerModel> _nurseries = [];
  List<Map<String, dynamic>> _suggestedSites = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    if (widget.initialLat != null && widget.initialLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animatedMapMove(LatLng(widget.initialLat!, widget.initialLng!), 18.0);
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      bool isAdmin = false;
      final String? userId = user?.uid;
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final role = doc.data()?['role'] as String?;
          isAdmin = role == 'admin';
        }
      }
      
      final trees = await _firestoreService.getPlantedTrees(userId: userId, isAdmin: isAdmin);
      final nurseries = await _firestoreService.getNurseries();
      final suggested = await _firestoreService.getSuggestedSites();
      if (mounted) {
        setState(() {
          _trees = trees;
          _nurseries = nurseries;
          _suggestedSites = suggested;
        });
      }
    } catch (e) {
      debugPrint('Error fetching map data: $e');
    }
  }

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
      duration: const Duration(milliseconds: 400),
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
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
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

  void _showNurseryDetails(NurseryMarkerModel nursery) {
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
                nursery.nurseryName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nursery.address,
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
                    nursery.phone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openMapsForDirections(
                      nursery.latitude,
                      nursery.longitude,
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

  void _showTreeDetails(TreeMarkerModel tree) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          tree.treeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${tree.location}'),
            Text('Planted by: ${tree.plantedBy} on ${tree.plantedDate}'),
            const SizedBox(height: 16),
            if (tree.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: tree.imageUrl,
                  height: 200,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Container(
                height: 150,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child:
                      Icon(CupertinoIcons.tree, size: 50, color: Colors.grey),
                ),
              ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openMapsForDirections(
                  tree.latitude,
                  tree.longitude,
                );
              },
              icon: const Icon(Icons.directions, color: Colors.white),
              label: Text(
                isMarathi ? 'मार्गदर्शक मिळवा' : 'Get Directions',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
        point: LatLng(n.latitude, n.longitude),
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () => _showNurseryDetails(n),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 1.5),
            ),
            child: const Icon(Icons.storefront, color: Colors.orange, size: 20),
          ),
        ),
      );
    }).toList();

    final List<Marker> suggestedMarkers = _suggestedSites.map((s) {
      final lat = (s['latitude'] as num).toDouble();
      final lng = (s['longitude'] as num).toDouble();
      return Marker(
        point: LatLng(lat, lng),
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Suggested Planting Site'),
                content: Text(s['description'] as String? ?? 'No description'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                ],
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 1.5),
            ),
            child: const Icon(Icons.flag, color: Colors.blue, size: 20),
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
              final code = context.locale.languageCode;
              if (code == 'en') {
                context.setLocale(const Locale('mr'));
              } else if (code == 'mr') {
                context.setLocale(const Locale('hi'));
              } else {
                context.setLocale(const Locale('en'));
              }
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
          _buildMapLayer(nurseryMarkers, suggestedMarkers),
          _buildSearchBar(),
          _buildLocateMeFab(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMapLayer(List<Marker> nurseryMarkers, List<Marker> suggestedMarkers) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(20.7002, 77.0082),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vasundhara.treeapp',
        ),
        MarkerLayer(
          markers: [...nurseryMarkers, ...suggestedMarkers],
        ),

        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            markers: _trees.map(
              (tree) => Marker(
                  point: LatLng(tree.latitude, tree.longitude),
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
                          CupertinoIcons.tree,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ).toList(),
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
                  CupertinoIcons.tree,
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
