import 'package:cloud_firestore/cloud_firestore.dart';

class NurseryMarkerModel {
  final String id;
  final String nurseryName;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final String imageUrl;

  NurseryMarkerModel({
    required this.id,
    required this.nurseryName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    required this.imageUrl,
  });

  factory NurseryMarkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NurseryMarkerModel(
      id: doc.id,
      nurseryName: data['nurseryName'] as String? ?? 'Unknown Nursery',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 73.8567,
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
