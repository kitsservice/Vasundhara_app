import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';

class CommunitiesListScreen extends StatelessWidget {
  const CommunitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinCommunitySheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: Text(
          'ui_key_235'.tr(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'ui_key_234'.tr(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Community based')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading communities'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No communities found.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final communityName = data['communityName'] ?? 'Unknown Community';
              final communityAddress = data['communityAddress'] ?? 'No address provided';
              final contactName = data['name'] ?? 'Unknown Contact';
              // Note: Phone number intentionally omitted for privacy

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              communityName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    communityAddress,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Contact: $contactName',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showJoinCommunitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select a Community to Join',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Community based').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No communities available to join.'));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final communityName = data['communityName'] ?? 'Unknown Community';
                        final communityId = docs[index].id;

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.people, color: Colors.white),
                          ),
                          title: Text(communityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['communityAddress'] ?? ''),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _joinCommunity(context, communityId, communityName),
                            child: const Text('Join'),
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
      },
    );
  }

  Future<void> _joinCommunity(BuildContext context, String communityId, String communityName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'joinedCommunityId': communityId,
        'joinedCommunityName': communityName,
      });

      // Notify Admin
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': 'Community Joined!',
        'message': '${user.displayName ?? 'A user'} joined the $communityName community.',
        'type': 'community_joined',
        'userName': user.displayName ?? 'Unknown',
        'communityName': communityName,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context); // Close the sheet
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully joined \$communityName!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to join: \$e')));
      }
    }
  }
}
