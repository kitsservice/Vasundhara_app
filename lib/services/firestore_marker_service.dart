import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tree_marker_model.dart';
import '../models/nursery_marker_model.dart';

class FirestoreMarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TreeMarkerModel>> getPlantedTrees({String? userId, bool isAdmin = false}) async {
    try {
      Query query = _firestore.collection('planted_trees').limit(500);
      if (!isAdmin && userId != null) {
        query = _firestore.collection('planted_trees').where('userId', isEqualTo: userId).limit(500);
      }
      final snapshot = await query.get();
          
      return snapshot.docs
          .map((doc) => TreeMarkerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching planted trees: $e');
      return [];
    }
  }

  Future<List<NurseryMarkerModel>> getNurseries() async {
    try {
      final snapshot = await _firestore.collection('nurseries').get();
      return snapshot.docs
          .map((doc) => NurseryMarkerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching nurseries: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestedSites() async {
    try {
      final snapshot = await _firestore.collection('suggested_sites').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching suggested sites: $e');
      return [];
    }
  }

  Future<void> addSuggestedSite(Map<String, dynamic> siteData) async {
    try {
      await _firestore.collection('suggested_sites').add(siteData);
    } catch (e) {
      debugPrint('Error adding suggested site: $e');
      rethrow;
    }
  }
}
