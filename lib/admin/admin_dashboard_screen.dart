import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'admin_stats_view.dart';
import 'admin_moderation_view.dart';
import 'admin_campaign_view.dart';
import 'admin_settings_view.dart';

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
    const AdminModerationView(), // Users (Mock routing to moderation for now)
    const SizedBox(), // Add (Handled by FAB)
    const AdminCampaignView(), // Campaigns
    const AdminSettingsView(), // Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildAdminDrawer(context),
      body: Stack(
        children: [
          // The background of the body should be slightly grey
          Positioned.fill(
            child: Container(color: const Color(0xFFF8F9FA)),
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
                  colors: [Color(0xFF0F7A3E), Color(0xFF165A31)],
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
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.bell,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () {},
                              ),
                              Positioned(
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
        onPressed: () {},
        backgroundColor: const Color(0xFF1B8A44),
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
              _buildNavItem(
                CupertinoIcons.square_grid_2x2_fill,
                'Dashboard',
                0,
              ),
              _buildNavItem(CupertinoIcons.person_3, 'Users', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(CupertinoIcons.speaker_3, 'Campaigns', 3),
              _buildNavItem(CupertinoIcons.settings, 'Settings', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF1B8A44) : Colors.grey.shade500;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
                colors: [Color(0xFF0F7A3E), Color(0xFF165A31)],
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
                    CupertinoIcons.shield_fill,
                    color: Color(0xFF165A31),
                    size: 30,
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
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
