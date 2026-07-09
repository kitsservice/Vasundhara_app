import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AdminUsersManagementScreen extends StatefulWidget {
  const AdminUsersManagementScreen({super.key});

  @override
  State<AdminUsersManagementScreen> createState() => _AdminUsersManagementScreenState();
}

class _AdminUsersManagementScreenState extends State<AdminUsersManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'user')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isBanned = data['isBanned'] ?? false;
                    final treesPlanted = data['totalTreesPlanted'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isBanned ? Colors.red.shade100 : AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            isBanned ? Icons.block : Icons.person,
                            color: isBanned ? Colors.red : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Unknown User',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['email'] ?? 'No email'),
                            const SizedBox(height: 4),
                            Text(
                              'Trees Planted: $treesPlanted',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (data['joinedCommunityName'] != null)
                              Text(
                                'Community: ${data['joinedCommunityName']}',
                                style: const TextStyle(color: Colors.indigo, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'ban') {
                              _toggleBanStatus(doc.id, isBanned);
                            } else if (val == 'badge') {
                              _awardBadge(context, doc.id);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'ban',
                              child: Text(isBanned ? 'Unban User' : 'Ban User', style: TextStyle(color: isBanned ? Colors.green : Colors.red)),
                            ),
                            const PopupMenuItem(
                              value: 'badge',
                              child: Text('Award Badge'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBanStatus(String userId, bool isBanned) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isBanned': !isBanned,
    });
  }

  Future<void> _awardBadge(BuildContext context, String userId) async {
    final TextEditingController badgeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Award Badge'),
        content: TextField(
          controller: badgeController,
          decoration: const InputDecoration(
            hintText: 'Enter badge ID (e.g., top_planter)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (badgeController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'unlockedBadges': FieldValue.arrayUnion([badgeController.text.trim()]),
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Badge awarded!')),
                  );
                }
              }
            },
            child: const Text('Award'),
          ),
        ],
      ),
    );
  }
}
