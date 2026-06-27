import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../widgets/professional_drawer.dart';
import '../widgets/home_hero_background.dart';
import '../widgets/pledge_dialog.dart';
import 'map_screen.dart';
import 'plant_tree_screen.dart';
import 'campaign_hub_screen.dart';
import 'my_forest_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().checkAndGenerateNotifications();
      context.read<UserProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const ProfessionalDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Invisible AppBar just to show the drawer icon nicely over the image
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            floating: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco, color: AppColors.primary, size: 28),
                SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      'Vasundhara',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Tree Plantation',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.bell),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isMarathi ? 'त्वरित क्रिया' : 'Quick Actions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        isMarathi ? 'सर्व पहा >' : 'View All >',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 400.ms),
                  const SizedBox(height: 20),

                  // 2x2 Grid of square cards
                  Row(
                    children: [
                      Expanded(
                        child: _SquareActionCard(
                          icon: CupertinoIcons.location_solid,
                          title: isMarathi ? 'ठिकाण जोडा' : 'Add Location',
                          iconColor: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MapScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SquareActionCard(
                          icon: CupertinoIcons.camera_fill,
                          title: isMarathi ? 'फोटो अपलोड' : 'Upload Photo',
                          iconColor: const Color(0xFF047857),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlantTreeScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SquareActionCard(
                          icon: Icons.handshake,
                          title: isMarathi ? 'शपथ घ्या' : 'Take Pledge',
                          iconColor: const Color(0xFF064E3B),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const PledgeDialog(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SquareActionCard(
                          icon: Icons.bar_chart_rounded,
                          title: isMarathi ? 'माझी प्रगती' : 'My Progress',
                          iconColor: const Color(0xFF6B7280),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyForestScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // Abhiyan Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD1FAE5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMarathi
                                    ? 'हरित वसुंधरा अभियानात सामील व्हा'
                                    : 'Join the Green Vasundhara Abhiyan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isMarathi
                                    ? 'उज्वल भविष्यासाठी बदलाचा भाग बना.'
                                    : 'Be a part of the change for a better tomorrow.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CampaignHubScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF047857),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size(120, 36),
                                ),
                                child: Text(
                                  isMarathi ? 'अधिक जाणून घ्या' : 'Know More',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Image.asset(
                            'assets/images/realistic_plant.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 700.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _SquareActionCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
