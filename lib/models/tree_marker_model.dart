import 'package:cloud_firestore/cloud_firestore.dart';

class TreeMarkerModel {
  final String id;
  final String treeName;
  final double latitude;
  final double longitude;
  final String plantedBy;
  final String plantedDate;
  final String imageUrl;
  final String status;
  final String location;

  TreeMarkerModel({
    required this.id,
    required this.treeName,
    required this.latitude,
    required this.longitude,
    required this.plantedBy,
    required this.plantedDate,
    required this.imageUrl,
    required this.status,
    required this.location,
  });

  factory TreeMarkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Handle datePlanted (which is a Timestamp when saved from UserProvider)
    String pDate = data['plantedDate'] as String? ?? '';
    if (data['datePlanted'] is Timestamp) {
      final dt = (data['datePlanted'] as Timestamp).toDate();
      pDate = '${dt.day}/${dt.month}/${dt.year}';
    }

    return TreeMarkerModel(
      id: doc.id,
      treeName: data['speciesName'] as String? ?? data['treeName'] as String? ?? 'Unknown Tree',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 73.8567,
      plantedBy: data['userName'] as String? ?? data['plantedBy'] as String? ?? 'Green Guardian',
      plantedDate: pDate,
      imageUrl: data['imageUrl'] as String? ?? '',
      status: data['status'] as String? ?? 'Unknown',
      location: data['location'] as String? ?? 'Unknown Location',
    );
  }
}
