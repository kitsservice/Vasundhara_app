import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class AdminModerationView extends StatefulWidget {
  const AdminModerationView({super.key});

  @override
  State<AdminModerationView> createState() => _AdminModerationViewState();
}

class _AdminModerationViewState extends State<AdminModerationView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Manager',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'Review tree uploads and manage user accounts.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Moderation Queue'),
                Tab(text: 'All Users'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildModerationTab(),
                const _UsersListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('planted_trees')
          .orderBy('datePlanted', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No trees planted yet.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _ModerationCard(
              index: index,
              data: data,
              docId: docs[index].id,
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 + (index * 50)))
                .slideY(begin: 0.1);
          },
        );
      },
    );
  }
}

class _UsersListTab extends StatelessWidget {
  const _UsersListTab();

  Future<void> _toggleUserStatus(String docId, String currentStatus) async {
    final newStatus = currentStatus == 'banned' ? 'active' : 'banned';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> _toggleUserRole(String docId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .update({'role': newRole});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final name = data['name'] ?? 'Unknown User';
            final trees = data['totalTreesPlanted'] ?? 0;
            final status = data['status'] ?? 'active';
            final role = data['role'] ?? 'user';

            final isBanned = status == 'banned';
            final isAdmin = role == 'admin';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isBanned
                        ? Colors.red.shade100
                        : AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        color: isBanned ? Colors.red : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration:
                                isBanned ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '$trees Trees Planted',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'ban') {
                        _toggleUserStatus(docId, status);
                      } else if (value == 'admin') {
                        _toggleUserRole(docId, role);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'ban',
                        child: Text(
                          isBanned ? 'Unban User' : 'Ban User',
                          style: TextStyle(
                            color: isBanned ? AppColors.primary : Colors.red,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'admin',
                        child: Text(isAdmin ? 'Revoke Admin' : 'Make Admin'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ModerationCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final String docId;

  const _ModerationCard({
    required this.index,
    required this.data,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = data['imageUrl'] ?? '';
    final String userName = data['userName'] ?? 'Unknown User';
    final String location = data['location'] ?? 'Unknown Location';
    final String speciesName = data['speciesName'] ?? 'Tree';
    final int quantity = data['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Placeholder with gradient overlay
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade900,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            CupertinoIcons.tree,
                            size: 80,
                            color: Colors.white24,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.tree,
                          size: 80,
                          color: Colors.white24,
                        ),
                ),
                // Gradient overlay
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.tree,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$quantity $speciesName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tree Rejected! (UI Only for now)'),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.redAccent.shade100,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tree Approved! (UI Only for now)'),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
  }
}
