import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'admin_stats_view.dart';
import 'admin_campaign_view.dart';
import 'admin_users_management_screen.dart';
import 'admin_settings_view.dart';
import 'admin_nursery_registration_sheet.dart';
import 'admin_nurseries_list_screen.dart';
import 'admin_communities_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _views = [
    const AdminStatsView(), // Dashboard
    const AdminUsersManagementScreen(), // Users
    const SizedBox(), // Add (Handled by FAB)
    const AdminCampaignView(), // Campaigns
    const AdminSettingsView(), // Settings
    const AdminCommunitiesView(), // Communities
  ];

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Notifications',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_notifications')
                    .orderBy('createdAt', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No new notifications.'));
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      final userName = data['userName'] ?? 'Unknown User';
                      final type = data['type'] ?? 'tree_planted';
                      
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
                      Color iconBg = AppColors.primary.withValues(alpha: 0.1);
                      Color iconColor = AppColors.primary;
                      String verb = ' successfully planted ';
                      String object = '${data['quantity'] ?? 1} trees';
                      Color objectColor = AppColors.primary;

                      if (type == 'donation_request') {
                        icon = CupertinoIcons.gift_fill;
                        iconBg = AppColors.secondary.withValues(alpha: 0.1);
                        iconColor = AppColors.secondary;
                        verb = ' submitted a new ';
                        object = 'Donation Request';
                        objectColor = AppColors.secondary;
                      } else if (type == 'growth_update_uploaded') {
                        icon = CupertinoIcons.photo_camera_solid;
                        iconBg = Colors.blue.withValues(alpha: 0.1);
                        iconColor = Colors.blue.shade700;
                        verb = ' uploaded a ';
                        object = '6-Month Growth Photo';
                        objectColor = Colors.blue.shade700;
                      } else if (type == 'badge_unlocked') {
                        icon = CupertinoIcons.rosette;
                        iconBg = Colors.orange.withValues(alpha: 0.1);
                        iconColor = Colors.orange.shade800;
                        verb = ' unlocked the ';
                        object = '${data['badgeId'] ?? ''} Badge';
                        objectColor = Colors.orange.shade800;
                      } else if (type == 'site_suggested') {
                        icon = CupertinoIcons.map_pin_ellipse;
                        iconBg = Colors.purple.withValues(alpha: 0.1);
                        iconColor = Colors.purple.shade700;
                        verb = ' suggested a new ';
                        object = 'Planting Site';
                        objectColor = Colors.purple.shade700;
                      } else if (type == 'nursery_registered') {
                        icon = CupertinoIcons.house_fill;
                        iconBg = Colors.teal.withValues(alpha: 0.1);
                        iconColor = Colors.teal.shade800;
                        verb = ' registered a new ';
                        object = 'Partner Nursery';
                        objectColor = Colors.teal.shade800;
                      } else if (type == 'community_joined') {
                        icon = CupertinoIcons.person_3_fill;
                        iconBg = Colors.indigo.withValues(alpha: 0.1);
                        iconColor = Colors.indigo.shade700;
                        verb = ' joined the community: ';
                        object = '${data['communityName'] ?? 'Unknown'}';
                        objectColor = Colors.indigo.shade700;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: verb,
                                      ),
                                      TextSpan(
                                        text: object,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: objectColor,
                                        ),
                                      ),
                                      const TextSpan(text: '!'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildAdminDrawer(context),
      body: Stack(
        children: [
          // The background of the body should be slightly grey
          Positioned.fill(
            child: Container(color: AppColors.background),
          ),

          // Curved Green Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260, // Total height to allow overlap
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Column(
                            children: [
                              Text(
                                'Admin Dashboard',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Vasundhara Tree Plantation',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.storefront,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminNurseriesListScreen(),
                                    ),
                                  );
                                },
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      CupertinoIcons.bell,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: _showNotifications,
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('admin_notifications')
                                        .where('isRead', isEqualTo: false)
                                        .limit(1)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                        return Positioned(
                                          right: 10,
                                          top: 10,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // The Main Scrollable Body
          Positioned.fill(
            top: 130, // Start below the text part of the header
            child: IndexedStack(
              index: _currentIndex,
              children: _views,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AdminNurseryRegistrationSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildNavItem(
                  CupertinoIcons.square_grid_2x2_fill,
                  'Dashboard',
                  0,
                ),
              ),
              Expanded(child: _buildNavItem(CupertinoIcons.person_3, 'Users', 1)),
              const SizedBox(width: 48), // Space for FAB
              Expanded(child: _buildNavItem(CupertinoIcons.speaker_3, 'Campaigns', 3)),
              Expanded(child: _buildNavItem(CupertinoIcons.settings, 'Settings', 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey.shade500;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    CupertinoIcons.tree,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin Portal',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@vasundhara.app',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(
              CupertinoIcons.square_grid_2x2,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Dashboard',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              CupertinoIcons.person_2,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Users',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              CupertinoIcons.settings,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 4;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.apartment,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Communities',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 5;
              });
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              CupertinoIcons.square_arrow_right,
              color: Colors.redAccent,
            ),
            title: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // close drawer
              context.read<AuthProvider>().signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
