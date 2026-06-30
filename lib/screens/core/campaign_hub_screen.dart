import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import 'plant_tree_screen.dart';
import '../../providers/user_provider.dart';
import 'donate_screen.dart';
import '../../widgets/campaign/campaign_info_sections.dart';
import '../../widgets/campaign/campaign_progress_section.dart';
import '../../widgets/campaign/campaign_leaderboard_preview.dart';

class CampaignHubScreen extends StatefulWidget {
  const CampaignHubScreen({super.key});

  @override
  State<CampaignHubScreen> createState() => _CampaignHubScreenState();
}

class _CampaignHubScreenState extends State<CampaignHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

    final leaderboard =
        context.select<UserProvider, dynamic>((p) => p.leaderboard);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isMarathi ? 'हरित वसुंधरा अभियान' : 'Green Vasundhara Abhiyan',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/forest_bg.png', // Fallback if exists, or use a container with color if it fails. Actually we will use a gradient to be safe.
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF047857), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MissionSection(isMarathi: isMarathi),
                  const SizedBox(height: 24),
                  WhyJoinSection(isMarathi: isMarathi),
                  const SizedBox(height: 30),
                  SeedBallsInitiative(isMarathi: isMarathi),
                  const SizedBox(height: 30),
                  ProgressSection(isMarathi: isMarathi),
                  const SizedBox(height: 40),
                  LeaderboardPreview(
                      isMarathi: isMarathi, leaderboard: leaderboard),
                  const SizedBox(height: 80), // Padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'donate',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonateScreen(),
                ),
              );
            },
            backgroundColor: Colors.white,
            icon: const Icon(
              CupertinoIcons.heart_solid,
              color: AppColors.primary,
            ),
            label: Text(
              isMarathi ? 'दान करा' : 'Donate',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().scale(delay: 900.ms),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'plant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantTreeScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(
              CupertinoIcons.leaf_arrow_circlepath,
              color: Colors.white,
            ),
            label: Text(
              isMarathi ? 'अभियानात सामील व्हा' : 'Plant for Abhiyan',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().scale(delay: 1000.ms),
        ],
      ),
    );
  }
}
