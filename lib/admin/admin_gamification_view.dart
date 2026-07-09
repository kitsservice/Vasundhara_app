import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class AdminGamificationView extends StatelessWidget {
  const AdminGamificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gamification & Leaderboard',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .orderBy('totalTreesPlanted', descending: true)
            .limit(50)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final name = data['name'] ?? 'Unknown User';
              final treesPlanted = data['totalTreesPlanted'] ?? 0;
              final locations = data['totalLocations'] ?? 0;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Trees: $treesPlanted | Locations: $locations', style: GoogleFonts.inter(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.gift_fill, color: Colors.orange),
                    onPressed: () {
                      _showRewardDialog(context, doc.id, name);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber; // Gold
    if (index == 1) return Colors.grey.shade400; // Silver
    if (index == 2) return Colors.orange.shade300; // Bronze
    return AppColors.primary;
  }

  void _showRewardDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Issue Badge to $userName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a badge to issue to this user:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(CupertinoIcons.star_circle_fill, color: Colors.amber),
                title: const Text('Top Contributor'),
                onTap: () => _issueBadge(context, userId, 'Top Contributor'),
              ),
              ListTile(
                leading: const Icon(Icons.eco, color: Colors.green),
                title: const Text('Green Guardian'),
                onTap: () => _issueBadge(context, userId, 'Green Guardian'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _issueBadge(BuildContext context, String userId, String badgeName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'badges': FieldValue.arrayUnion([badgeName]),
      });
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Issued $badgeName badge successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error issuing badge: $e');
    }
  }
}
