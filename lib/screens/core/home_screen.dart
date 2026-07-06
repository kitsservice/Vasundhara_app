import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/professional_drawer.dart';
import '../../widgets/home_hero_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifications_screen.dart';
import 'dart:ui';
import '../../widgets/abhiyan_banner.dart';
import '../../widgets/quick_actions_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _checkAndShowAnnouncement() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeenId = prefs.getString('last_seen_announcement_id');

      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final docId = doc.id;

        if (lastSeenId != docId) {
          if (mounted) {
            final data = doc.data();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        data['type'] == 'organized_program'
                            ? CupertinoIcons.calendar_today
                            : CupertinoIcons.speaker_3_fill,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['title'] ?? 'New Update',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    data['message'] ?? '',
                    style: GoogleFonts.inter(fontSize: 15, height: 1.5),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        prefs.setString('last_seen_announcement_id', docId);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Got it!',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking announcement: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().checkAndGenerateNotifications();
      context.read<UserProvider>().fetchNotifications();
      _checkAndShowAnnouncement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const ProfessionalDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Glassmorphism AppBar over the image
          SliverAppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            elevation: 0,
            pinned: true,
            floating: false,
            stretch: true,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.primary),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      'Vasundhara',
                      style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Tree Plantation',
                      style: GoogleFonts.inter(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.globe),
                tooltip: 'Toggle Language',
                onPressed: () {
                  context.read<SettingsProvider>().toggleLanguage();
                },
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.bell),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        if (userProvider.unreadNotificationsCount > 0)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${userProvider.unreadNotificationsCount}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.15, 1.15),
                                  duration: 1000.ms,
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .scale(
                                  begin: const Offset(1.15, 1.15),
                                  end: const Offset(1, 1),
                                  duration: 1000.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          const HomeHeroBackground(),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: Column(
                children: [
                  const QuickActionsGrid(),

                  const SizedBox(height: 40),

                  // Abhiyan Banner
                  const AbhiyanBannerWidget()
                      .animate()
                      .fade(delay: 700.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
