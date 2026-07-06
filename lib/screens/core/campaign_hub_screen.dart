import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Stream<DocumentSnapshot> _campaignStream;

  @override
  void initState() {
    super.initState();
    _campaignStream = FirebaseFirestore.instance
        .collection('admin')
        .doc('campaign')
        .snapshots();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

    final leaderboard =
        context.select<UserProvider, dynamic>((p) => p.leaderboard);

    return StreamBuilder<DocumentSnapshot>(
      stream: _campaignStream,
      builder: (context, snapshot) {
        String programType = 'Tree Plantation';
        String customTitle = '';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          programType = data?['programType'] ?? 'Tree Plantation';
          customTitle = data?['title'] ?? '';
        }

        String displayTitle = '';
        List<Color> appBarGradient = [
          const Color(0xFF047857),
          const Color(0xFF10B981),
        ];
        IconData actionIcon = CupertinoIcons.leaf_arrow_circlepath;
        String actionLabel =
            isMarathi ? 'अभियानात सामील व्हा' : 'Plant for Abhiyan';
        Color primaryActionColor = AppColors.primary;

        if (programType == 'Facilitation Program') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : (isMarathi ? 'सुविधा कार्यक्रम' : 'Facilitation Program');
          appBarGradient = [Colors.blue.shade800, Colors.blue.shade500];
          actionIcon = CupertinoIcons.person_3_fill;
          actionLabel = isMarathi ? 'सामील व्हा' : 'Join Program';
          primaryActionColor = Colors.blue.shade700;
        } else if (programType == 'Awareness Drive') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : (isMarathi ? 'जागरूकता मोहीम' : 'Awareness Drive');
          appBarGradient = [Colors.orange.shade800, Colors.orange.shade500];
          actionIcon = CupertinoIcons.speaker_3_fill;
          actionLabel = isMarathi ? 'समुदायात सामील व्हा' : 'Join the Community';
          primaryActionColor = Colors.orange.shade700;
        } else {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : (isMarathi
                  ? 'हरित वसुंधरा अभियान'
                  : 'Green Vasundhara Abhiyan');
          appBarGradient = [const Color(0xFF047857), const Color(0xFF10B981)];
          actionIcon = CupertinoIcons.leaf_arrow_circlepath;
          actionLabel = isMarathi ? 'अभियानात सामील व्हा' : 'Plant for Abhiyan';
          primaryActionColor = AppColors.primary;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: primaryActionColor,
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    displayTitle,
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
                        cacheWidth: 800,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: appBarGradient,
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
                        isMarathi: isMarathi,
                        leaderboard: leaderboard,
                      ),
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
                backgroundColor: primaryActionColor,
                icon: Icon(
                  actionIcon,
                  color: Colors.white,
                ),
                label: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().scale(delay: 1000.ms),
            ],
          ),
        );
      },
    );
  }
}
