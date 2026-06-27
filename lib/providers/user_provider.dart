import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PlantedTree {
  final String speciesName;
  final DateTime datePlanted;
  final String location;
  final int quantity;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  PlantedTree({
    required this.speciesName,
    required this.datePlanted,
    required this.location,
    required this.quantity,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'speciesName': speciesName,
      'datePlanted': Timestamp.fromDate(datePlanted),
      'location': location,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PlantedTree.fromMap(Map<String, dynamic> map) {
    return PlantedTree(
      speciesName: map['speciesName'] ?? '',
      datePlanted: (map['datePlanted'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }
}

class UserProvider extends ChangeNotifier {
  final List<PlantedTree> _plantedTrees = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !(n['isRead'] ?? false)).length;

  List<PlantedTree> get plantedTrees => _plantedTrees;

  int get totalTreesPlanted =>
      _plantedTrees.fold(0, (total, item) => total + item.quantity);
  int get totalTreesSurvived =>
      (totalTreesPlanted * 0.85).toInt(); // Assuming 85% survival rate
  int get totalLocations => _plantedTrees.map((e) => e.location).toSet().length;

  void listenToPlantedTrees() {
    _subscription?.cancel();
    _subscription = _firestore.collection('planted_trees').snapshots().listen(
      (snapshot) {
        _plantedTrees.clear();
        for (var doc in snapshot.docs) {
          _plantedTrees.add(PlantedTree.fromMap(doc.data()));
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error listening to trees: $e');
      },
    );
  }

  Future<void> fetchPlantedTrees() async {
    // Keeping this for backwards compatibility if needed, but we should use the listener
    listenToPlantedTrees();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> fetchLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalTreesPlanted', descending: true)
          .limit(10)
          .get();

      _leaderboard = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Green Guardian',
          'trees': data['totalTreesPlanted'] ?? 0,
          'uid': doc.id,
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    }
  }

  Future<void> fetchNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notifId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notifId)
          .update({'isRead': true});

      final index = _notifications.indexWhere((n) => n['id'] == notifId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  Future<void> checkAndGenerateNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Automatically generate 6-month reminder notifications for old trees
    final now = DateTime.now();
    for (var tree in _plantedTrees) {
      final difference = now.difference(tree.datePlanted).inDays;
      if (difference >= 180) {
        // 6 months
        // Check if we already notified for this tree recently
        final notifExists = _notifications.any(
          (n) =>
              n['type'] == '6_month_update' &&
              n['treeSpecies'] == tree.speciesName,
        );

        if (!notifExists) {
          final notifData = {
            'type': '6_month_update',
            'title': 'Growth Update Due!',
            'message':
                'It has been 6 months since you planted your ${tree.speciesName}. Please upload a new growth photo to track its progress!',
            'treeSpecies': tree.speciesName,
            'isRead': false,
            'createdAt': Timestamp.now(),
          };

          final docRef = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('notifications')
              .add(notifData);

          notifData['id'] = docRef.id;
          _notifications.insert(0, notifData);
          notifyListeners();
        }
      }
    }
  }

  Future<void> plantTree(PlantedTree tree) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('No user logged in to plant tree.');
      return;
    }
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final treeRef = userRef.collection('trees').doc();
      final globalTreeRef =
          _firestore.collection('planted_trees').doc(treeRef.id);

      final treeData = tree.toMap();
      treeData['userId'] = user.uid;
      treeData['userName'] = user.displayName ?? 'Green Guardian';

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        transaction.set(globalTreeRef, treeData);
        transaction.set(treeRef, treeData);

        if (!userSnapshot.exists) {
          transaction.set(userRef, {
            'name': user.displayName ?? 'Green Guardian',
            'totalTreesPlanted': tree.quantity,
          });
        } else {
          transaction.update(userRef, {
            'totalTreesPlanted': FieldValue.increment(tree.quantity),
          });
        }
      });

      _plantedTrees.add(tree);
      notifyListeners();
    } catch (e) {
      debugPrint('Error planting tree: $e');
    }
  }
}
