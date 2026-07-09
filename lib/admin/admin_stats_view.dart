import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'admin_users_list_screen.dart';
import 'admin_verify_trees_screen.dart';
import 'admin_suggested_sites_screen.dart';
import 'admin_donations_screen.dart';
import 'admin_global_map_screen.dart';
import 'admin_campaign_view.dart';

class AdminStatsView extends StatefulWidget {
  const AdminStatsView({super.key});

  @override
  State<AdminStatsView> createState() => _AdminStatsViewState();
}

class _AdminStatsViewState extends State<AdminStatsView> {
  int _userCount = 0;
  int _totalTrees = 0;
  int _totalLocations = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final userQuery =
          await FirebaseFirestore.instance.collection('users').count().get();
      _userCount = userQuery.count ?? 0;

      final treesSnapshot =
          await FirebaseFirestore.instance.collection('planted_trees').get();
      int treesSum = 0;
      final Set<String> locations = {};

      for (var doc in treesSnapshot.docs) {
        final data = doc.data();
        treesSum += (data['quantity'] as num?)?.toInt() ?? 1;
        if (data['latitude'] != null && data['longitude'] != null) {
          locations.add('${data['latitude']}_${data['longitude']}');
        }
      }

      _totalTrees = treesSum;
      _totalLocations = locations.length;
    } catch (e) {
      debugPrint('Error fetching admin stats: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overlapping Welcome Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.tree,
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Manage and monitor all activities',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.calendar,
                            color: Color(0xFF16A34A),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overview',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchStats,
                    child: Text(
                      'Refresh',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Fetching Stats Grid
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('planted_trees').snapshots(),
              builder: (context, treeSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, userSnapshot) {
                    
                    int liveTrees = 0;
                    int liveSurvived = 0;
                    int liveLocations = 0;
                    int liveUsers = 0;

                    if (treeSnapshot.hasData) {
                      final Set<String> locs = {};
                      for (var doc in treeSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final qty = (data['quantity'] as num?)?.toInt() ?? 1;
                        liveTrees += qty;
                        
                        final status = (data['status'] as String?)?.toLowerCase() ?? 'pending';
                        // A tree is only 'survived' if it has been explicitly verified by the admin after 6 months
                        if (status == 'survived') {
                          liveSurvived += qty;
                        }

                        if (data['latitude'] != null && data['longitude'] != null) {
                          locs.add('${data['latitude']}_${data['longitude']}');
                        }
                      }
                      liveLocations = locs.length;
                    } else {
                      liveTrees = _totalTrees;
                      liveSurvived = (_totalTrees * 0.85).round();
                      liveLocations = _totalLocations;
                    }

                    if (userSnapshot.hasData) {
                      liveUsers = userSnapshot.data!.docs.where((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return d['isBanned'] != true;
                      }).length;
                    } else {
                      liveUsers = _userCount;
                    }

                    String survivalRate = '0%';
                    if (liveTrees > 0) {
                      survivalRate = '~${((liveSurvived / liveTrees) * 100).round()}%';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridCard(
                                  'Total Trees Planted',
                                  NumberFormat('#,###').format(liveTrees),
                                  'Live',
                                  CupertinoIcons.tree,
                                  const Color(0xFF16A34A),
                                  const Color(0xFFF0FDF4),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminVerifyTreesScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGridCard(
                                  'Trees Survived',
                                  NumberFormat('#,###').format(liveSurvived), 
                                  survivalRate,
                                  CupertinoIcons.tree,
                                  const Color(0xFF3B82F6),
                                  const Color(0xFFEFF6FF),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminVerifyTreesScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridCard(
                                  'Locations',
                                  liveLocations.toString(),
                                  'Live',
                                  CupertinoIcons.location_solid,
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFFFFBEB),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminGlobalMapScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGridCard(
                                  'Active Users',
                                  liveUsers.toString(),
                                  'Live',
                                  CupertinoIcons.person_2_fill,
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFF5F3FF),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminUsersListScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Quick Actions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      CupertinoIcons.tree,
                      'Add Campaign',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF2E7D32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  'Campaign & Events',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 0,
                                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                              ),
                              backgroundColor: AppColors.background,
                              body: const AdminCampaignView(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      CupertinoIcons.location_solid,
                      'Suggested Sites',
                      const Color(0xFFEFF6FF),
                      const Color(0xFF1D4ED8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminSuggestedSitesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      CupertinoIcons.tree,
                      'Verify Trees',
                      const Color(0xFFFFF7ED),
                      const Color(0xFFC2410C),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminVerifyTreesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      CupertinoIcons.chart_bar_alt_fill,
                      'Donations',
                      const Color(0xFFF5F3FF),
                      const Color(0xFF6D28D9),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDonationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Activities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activities',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_notifications')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: Text('No recent activities.')),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final type = data['type'] ?? 'tree_planted';
                        final quantity = data['quantity'] ?? data['amount'] ?? 1;
                        final userName = data['userName'] ?? 'Unknown User';

                        // Calculate time ago (approx)
                        String timeStr = 'Just now';
                        if (data['createdAt'] != null) {
                          final DateTime date =
                              (data['createdAt'] as Timestamp).toDate();
                          final diff = DateTime.now().difference(date);
                          if (diff.inMinutes < 60) {
                            timeStr = '${diff.inMinutes} min ago';
                          } else if (diff.inHours < 24) {
                            timeStr = '${diff.inHours} hours ago';
                          } else {
                            timeStr = '${diff.inDays} days ago';
                          }
                        }

                        IconData icon = CupertinoIcons.tree;
                        Color iconBg = const Color(0xFFE8F5E9);
                        Color iconColor = const Color(0xFF2E7D32);
                        String title = '$quantity Tree(s) Planted';
                        String location = 'Live App Upload';
                        
                        if (type == 'donation_request') {
                          icon = CupertinoIcons.gift_fill;
                          iconBg = const Color(0xFFEFF6FF);
                          iconColor = const Color(0xFF1D4ED8);
                          title = 'Donation Request';
                          location = 'Awaiting Approval';
                        } else if (type == 'growth_update_uploaded') {
                          icon = CupertinoIcons.photo_camera_solid;
                          iconBg = Colors.blue.shade50;
                          iconColor = Colors.blue.shade700;
                          title = '6-Month Growth Photo';
                          location = 'Needs Verification';
                        } else if (type == 'badge_unlocked') {
                          icon = CupertinoIcons.rosette;
                          iconBg = Colors.orange.shade50;
                          iconColor = Colors.orange.shade800;
                          title = 'Badge Unlocked: ${data['badgeId'] ?? ''}';
                          location = 'Gamification';
                        } else if (type == 'site_suggested') {
                          icon = CupertinoIcons.map_pin_ellipse;
                          iconBg = Colors.purple.shade50;
                          iconColor = Colors.purple.shade700;
                          title = 'New Site Suggested';
                          location = 'Awaiting Review';
                        } else if (type == 'nursery_registered') {
                          icon = CupertinoIcons.house_fill;
                          iconBg = Colors.teal.shade50;
                          iconColor = Colors.teal.shade800;
                          title = 'Nursery Registered';
                          location = 'Partner Network';
                        } else if (type == 'community_joined') {
                          icon = CupertinoIcons.person_3_fill;
                          iconBg = Colors.indigo.shade50;
                          iconColor = Colors.indigo.shade700;
                          title = 'Joined Community';
                          location = data['communityName'] ?? 'Community';
                        }

                        final isLast = doc == snapshot.data!.docs.last;

                        return Column(
                          children: [
                            _buildActivityRow(
                              icon: icon,
                              iconBg: iconBg,
                              iconColor: iconColor,
                              title: title,
                              subtitle: 'By $userName',
                              location: location,
                              time: timeStr,
                              status: 'Added',
                              statusColor: const Color(0xFF16A34A),
                              statusBg: const Color(0xFFDCFCE7),
                            ),
                            if (!isLast)
                              const Divider(
                                height: 1,
                                indent: 70,
                                endIndent: 20,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color mainColor,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bgColor.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF4B5563),
              ),
            ),
            Row(
              children: [
                Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'database',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    {VoidCallback? onTap,}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String location,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
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
  }
}
