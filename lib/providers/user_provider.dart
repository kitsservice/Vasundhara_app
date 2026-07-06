import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PlantedTree {
  final String? id;
  final String speciesName;
  final DateTime datePlanted;
  final String location;
  final int quantity;
  final String? imageUrl;
  final String? growthImageUrl;
  final double? latitude;
  final double? longitude;

  PlantedTree({
    this.id,
    required this.speciesName,
    required this.datePlanted,
    required this.location,
    required this.quantity,
    this.imageUrl,
    this.growthImageUrl,
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
      'growthImageUrl': growthImageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PlantedTree.fromMap(Map<String, dynamic> map, {String? id}) {
    return PlantedTree(
      id: id,
      speciesName: map['speciesName'] ?? '',
      datePlanted: (map['datePlanted'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      growthImageUrl: map['growthImageUrl'],
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
  bool _isListening = false;

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        clearData();
      } else {
        fetchPlantedTrees();
      }
    });
  }

  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !(n['isRead'] ?? false)).length;

  final List<String> _unlockedBadges = [];
  List<String> get unlockedBadges => _unlockedBadges;

  List<PlantedTree> get plantedTrees => _plantedTrees;

  int get totalTreesPlanted =>
      _plantedTrees.fold(0, (total, item) => total + item.quantity);
  int get totalTreesSurvived =>
      (totalTreesPlanted * 0.85).toInt(); // Assuming 85% survival rate
  int get totalLocations => _plantedTrees.map((e) => e.location).toSet().length;

  void listenToPlantedTrees() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Guard: only start one subscription
    if (_isListening) return;
    _isListening = true;
    _subscription?.cancel();
    _subscription = _firestore
        .collection('planted_trees')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        _plantedTrees.clear();
        for (var doc in snapshot.docs) {
          _plantedTrees.add(PlantedTree.fromMap(doc.data(), id: doc.id));
        }
        _plantedTrees.sort((a, b) => b.datePlanted.compareTo(a.datePlanted));
        notifyListeners();
      },
      onError: (e) {
        _isListening = false;
        debugPrint('Error listening to trees: $e');
      },
    );
  }

  Future<void> fetchPlantedTrees() async {
    listenToPlantedTrees();
  }

  void clearData() {
    _subscription?.cancel();
    _isListening = false;
    _plantedTrees.clear();
    _notifications.clear();
    _unlockedBadges.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _isListening = false;
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
      final personalFuture = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      final globalFuture = _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      final results = await Future.wait([personalFuture, globalFuture]);
      final personalSnapshot = results[0];
      final globalSnapshot = results[1];

      final allNotifs = <Map<String, dynamic>>[];

      for (var doc in personalSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        allNotifs.add(data);
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final lastCleared =
          userDoc.data()?['lastClearedAnnouncementsTime'] as Timestamp?;

      for (var doc in globalSnapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;

        if (lastCleared != null && createdAt != null) {
          if (createdAt.compareTo(lastCleared) <= 0) {
            continue;
          }
        }

        data['id'] = doc.id;
        // Global announcements are unread by default, maybe handled differently in UI
        allNotifs.add(data);
      }

      // Sort combined list by createdAt descending
      allNotifs.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      _notifications = allNotifs;
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

  Future<void> clearAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final personalDocs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .get();

      final batch = _firestore.batch();
      for (var doc in personalDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore.collection('users').doc(user.uid).set(
        {
          'lastClearedAnnouncementsTime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _notifications.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
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

  Future<void> uploadGrowthPhoto(String treeId, String growthImageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      // Update the user's specific tree document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trees')
          .doc(treeId)
          .update({'growthImageUrl': growthImageUrl});

      // Update the global planted_trees document
      await _firestore
          .collection('planted_trees')
          .doc(treeId)
          .update({'growthImageUrl': growthImageUrl});

      // Find it in the local list and update
      final index = _plantedTrees.indexWhere((tree) => tree.id == treeId);
      if (index != -1) {
        final oldTree = _plantedTrees[index];
        _plantedTrees[index] = PlantedTree(
          id: oldTree.id,
          speciesName: oldTree.speciesName,
          datePlanted: oldTree.datePlanted,
          location: oldTree.location,
          quantity: oldTree.quantity,
          imageUrl: oldTree.imageUrl,
          growthImageUrl: growthImageUrl, // the new URL
          latitude: oldTree.latitude,
          longitude: oldTree.longitude,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error uploading growth photo: $e');
    }
  }

  Future<void> unlockBadge(String badgeId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_unlockedBadges.contains(badgeId)) {
      _unlockedBadges.add(badgeId);
      notifyListeners();

      // In a real app, save to Firestore:
      try {
        await _firestore.collection('users').doc(user.uid).set(
          {
            'unlockedBadges': FieldValue.arrayUnion([badgeId]),
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Error unlocking badge: $e');
      }
    }
  }
}
