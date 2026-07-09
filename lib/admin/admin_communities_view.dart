import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class AdminCommunitiesView extends StatelessWidget {
  const AdminCommunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Communities Management',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Admin Only',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage all registered community accounts and view their private contact details.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Community based')
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading communities'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No community accounts registered yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final communityName = data['communityName'] ?? 'Unknown Community';
                    final communityAddress = data['communityAddress'] ?? 'No address provided';
                    final contactName = data['name'] ?? 'Unknown Contact';
                    final contactPhone = data['contactPhone'] ?? 'No phone provided';
                    final email = data['email'] ?? 'No email';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.apartment, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      communityName,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      communityAddress,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<AggregateQuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .where('joinedCommunityId', isEqualTo: docs[index].id)
                                          .count()
                                          .get(),
                                      builder: (context, countSnapshot) {
                                        if (countSnapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Members: ...', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold));
                                        }
                                        return Text(
                                          'Members: ${countSnapshot.data?.count ?? 0}',
                                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Community?'),
                                      content: Text('Are you sure you want to delete $communityName? This will revert their role to a standard user.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await FirebaseFirestore.instance.collection('users').doc(docs[index].id).update({
                                      'role': 'user',
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$communityName deleted successfully.')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoRow(Icons.person, 'Contact Person', contactName),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (email != 'No email') {
                                      final url = Uri.parse('mailto:$email');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    }
                                  },
                                  child: _buildInfoRow(Icons.email, 'Email Address', email, isLink: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, color: AppColors.secondary),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Private Contact Number (Admin Only)',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      contactPhone,
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  decoration: isLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
