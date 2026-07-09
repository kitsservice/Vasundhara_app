import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestedSiteModel {
  final String id;
  final double latitude;
  final double longitude;
  final String description;
  final String userId;
  final DateTime timestamp;

  SuggestedSiteModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.userId,
    required this.timestamp,
  });

  factory SuggestedSiteModel.fromMap(Map<String, dynamic> data, String id) {
    return SuggestedSiteModel(
      id: id,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
