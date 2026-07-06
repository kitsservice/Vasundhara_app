import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tree_marker_model.dart';
import '../models/nursery_marker_model.dart';

class FirestoreMarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TreeMarkerModel>> getPlantedTrees() async {
    try {
      final snapshot = await _firestore.collection('planted_trees').get();
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
}
