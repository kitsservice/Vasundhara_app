import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'plant_tree_screen.dart';
import '../../providers/user_provider.dart';
import 'donate_screen.dart';
import '../../widgets/campaign/campaign_info_sections.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    final userProvider = context.watch<UserProvider>();
    final int pledgeTarget = userProvider.pledgeTarget;
    final int totalPlanted = userProvider.plantedTrees.fold(0, (total, t) => (total) + t.quantity);

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
            'ui_key_17'.tr();
        Color primaryActionColor = AppColors.primary;

        if (programType == 'Facilitation Program') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_18'.tr());
          appBarGradient = [Colors.blue.shade800, Colors.blue.shade500];
          actionIcon = CupertinoIcons.person_3_fill;
          actionLabel = 'ui_key_19'.tr();
          primaryActionColor = Colors.blue.shade700;
        } else if (programType == 'Awareness Drive') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_20'.tr());
          appBarGradient = [Colors.orange.shade800, Colors.orange.shade500];
          actionIcon = CupertinoIcons.speaker_3_fill;
          actionLabel = 'ui_key_21'.tr();
          primaryActionColor = Colors.orange.shade700;
        } else {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_22'.tr());
          appBarGradient = [const Color(0xFF047857), const Color(0xFF10B981)];
          actionIcon = CupertinoIcons.leaf_arrow_circlepath;
          actionLabel = 'ui_key_23'.tr();
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
                      if (pledgeTarget > 0) ...[
                        _buildPledgeSection(pledgeTarget, totalPlanted, isMarathi),
                        const SizedBox(height: 24),
                      ],
                      WhyJoinSection(isMarathi: isMarathi),
                      const SizedBox(height: 30),
                      SeedBallsInitiative(isMarathi: isMarathi),
                      const SizedBox(height: 30),
                      VasundharaAbhiyanInfoSection(isMarathi: isMarathi),
                      const SizedBox(height: 30),
                      GreenEarthInfoSection(isMarathi: isMarathi),
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
                  'ui_key_24'.tr(),
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

  Widget _buildPledgeSection(int target, int planted, bool isMarathi) {
    final double progress = (planted / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isMarathi ? 'माझा हरित संकल्प' : 'My Green Pledge', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isMarathi ? 'लक्ष्य' : 'Target', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text(isMarathi ? '$target झाडे' : '$target Trees', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.green.shade50,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isMarathi ? '$planted / $target लावली' : '$planted / $target planted',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
