import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;
import '../../theme/app_colors.dart';
import '../../widgets/nursery_card.dart';
import 'nursery_storefront_screen.dart';

class NurseryScreen extends StatefulWidget {
  const NurseryScreen({super.key});

  @override
  State<NurseryScreen> createState() => _NurseryScreenState();
}

class _NurseryScreenState extends State<NurseryScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _locationError = false;

  final List<Map<String, dynamic>> _processedNurseries = [];

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      final loc.Location location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _locationError = true;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = true;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = true;
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _locationError = true;
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ui_key_85'.tr()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final code = context.locale.languageCode;
if (code == 'en') {
  context.setLocale(const Locale('mr'));
} else if (code == 'mr') {
  context.setLocale(const Locale('hi'));
} else {
  context.setLocale(const Locale('en'));
}

              });
            },
            child: Text(
              'ui_key_86'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _locationError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.location_slash,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ui_key_87'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoadingLocation = true;
                              _locationError = false;
                            });
                            _fetchUserLocation();
                          },
                          child: Text(
                            'ui_key_88'.tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('nurseries')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'ui_key_89'.tr(),
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    // Process and sort nurseries
                    final docs = snapshot.data!.docs;
                    _processedNurseries.clear();

                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final location = data['location'] as GeoPoint?;
                      double distanceInMeters = double.infinity;

                      if (location != null && _currentPosition != null) {
                        distanceInMeters = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          location.latitude,
                          location.longitude,
                        );
                      }

                      _processedNurseries.add({
                        'id': doc.id,
                        'name_en': data['name_en'] ?? 'Unknown',
                        'ownerName': data['ownerName'] ?? 'Unknown Owner',
                        'mobileNo': data['mobileNo'] ?? 'No contact info',
                        'address': data['address'] ?? 'No address provided',
                        'plants': data['plants'] ?? '',
                        'rating': data['rating'] ?? 5.0,
                        'distanceMeters': distanceInMeters,
                      });
                    }

                    _processedNurseries.sort(
                      (a, b) => (a['distanceMeters'] as double)
                          .compareTo(b['distanceMeters'] as double),
                    );

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio:
                            0.85, // Almost square, adjusted slightly to comfortably fit the text
                      ),
                      itemCount: _processedNurseries.length,
                      itemBuilder: (context, index) {
                        final nursery = _processedNurseries[index];

                        String distanceText;
                        final double m = nursery['distanceMeters'];
                        if (m == double.infinity) {
                          distanceText = 'Unknown';
                        } else if (m < 1000) {
                          distanceText = '${m.toStringAsFixed(0)} m';
                        } else {
                          distanceText = '${(m / 1000).toStringAsFixed(1)} km';
                        }

                        return NurseryCard(
                          nursery: nursery,
                          distanceText: distanceText,
                          isMarathi: isMarathi,
                          onCardTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NurseryStorefrontScreen(
                                  nurseryData: nursery,
                                  nurseryId: nursery['id'],
                                ),
                              ),
                            );
                          },
                          onContactTap: () async {
                            final mobileNo = nursery['mobileNo']?.toString() ?? '';
                            if (mobileNo.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'ui_key_90'.tr(),
                                  ),
                                ),
                              );
                              return;
                            }
                            final Uri url = Uri.parse('tel:$mobileNo');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'ui_key_91'.tr(),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
