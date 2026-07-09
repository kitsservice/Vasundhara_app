import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../services/firestore_marker_service.dart';
import '../models/tree_marker_model.dart';
import '../models/nursery_marker_model.dart';
import 'package:location/location.dart';

class AdminGlobalMapScreen extends StatefulWidget {
  const AdminGlobalMapScreen({super.key});

  @override
  State<AdminGlobalMapScreen> createState() => _AdminGlobalMapScreenState();
}

class _AdminGlobalMapScreenState extends State<AdminGlobalMapScreen> {
  final MapController _mapController = MapController();
  List<TreeMarkerModel> _trees = [];
  List<NurseryMarkerModel> _nurseries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final markerService = FirestoreMarkerService();
      final trees = await markerService.getPlantedTrees(isAdmin: true);
      final nurseries = await markerService.getNurseries();
      
      LatLng? userLocation;
      try {
        final location = Location();
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
        }
        
        PermissionStatus permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
        }
        
        if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
          final locData = await location.getLocation();
          if (locData.latitude != null && locData.longitude != null) {
            userLocation = LatLng(locData.latitude!, locData.longitude!);
          }
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }
      
      if (mounted) {
        setState(() {
          _trees = trees;
          _nurseries = nurseries;
          _isLoading = false;
        });
        
        if (userLocation != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(userLocation!, 11.0); // Center map on user location
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading map data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Global Impact Map',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _trees.isNotEmpty 
                        ? LatLng(_trees.first.latitude, _trees.first.longitude) 
                        : const LatLng(20.5937, 78.9629), // India center
                    initialZoom: 5.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vasundhara.app',
                    ),
                    MarkerLayer(
                      markers: [
                        ..._trees.map((tree) => Marker(
                              point: LatLng(tree.latitude, tree.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showTreeInfo(tree),
                                child: const Icon(
                                  CupertinoIcons.tree,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              ),
                            ),),
                        ..._nurseries.map((nursery) => Marker(
                              point: LatLng(nursery.latitude, nursery.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showNurseryInfo(nursery),
                                child: const Icon(
                                  Icons.storefront,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                              ),
                            ),),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegend(CupertinoIcons.tree, AppColors.primary, 'Planted Trees (${_trees.length})'),
                        _buildLegend(Icons.storefront, Colors.orange, 'Nurseries (${_nurseries.length})'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegend(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  void _showTreeInfo(TreeMarkerModel tree) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tree.treeName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Planted By: ${tree.plantedBy}', style: GoogleFonts.inter(fontSize: 14)),
              Text('Status: ${tree.status.toUpperCase()}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${tree.latitude},${tree.longitude}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
                    }
                  }
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tree.location != 'Unknown Location' && tree.location.isNotEmpty 
                            ? tree.location 
                            : '${tree.latitude.toStringAsFixed(4)}, ${tree.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${tree.latitude},${tree.longitude}');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(CupertinoIcons.car_detailed, color: Colors.white),
                  label: const Text('Navigate Here', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNurseryInfo(NurseryMarkerModel nursery) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nursery.nurseryName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${nursery.latitude},${nursery.longitude}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
                    }
                  }
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nursery.address.isNotEmpty 
                            ? nursery.address 
                            : '${nursery.latitude.toStringAsFixed(4)}, ${nursery.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.inter(
                          color: Colors.orange.shade800,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${nursery.latitude},${nursery.longitude}');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(CupertinoIcons.car_detailed, color: Colors.white),
                  label: const Text('Navigate Here', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
