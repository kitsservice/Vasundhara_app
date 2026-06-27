import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import 'plant_tree_screen.dart';
import '../providers/user_provider.dart';

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
    const double progress = 0.68; // Dummy progress (68%)
    const int currentTrees = 34000;
    const int targetTrees = 50000;

    final leaderboard = context.select<UserProvider, dynamic>((p) => p.leaderboard);

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
                  // Campaign Info
                  Text(
                    isMarathi ? 'आमचे ध्येय' : 'Our Mission',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(),
                  const SizedBox(height: 10),
                  Text(
                    isMarathi
                        ? 'हरित वसुंधरा अभियान हा आपल्या शहराला पुन्हा हिरवेगार बनवण्याचा एक उपक्रम आहे. एक झाड लावून हवामान बदलाशी लढण्यासाठी आमच्यात सामील व्हा.'
                        : 'The Green Vasundhara Abhiyan is a community-driven initiative to restore our urban canopy. Join us in fighting climate change, one tree at a time.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),

                  const SizedBox(height: 30),

                  // Progress Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMarathi ? 'प्रगती' : 'Campaign Progress',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$currentTrees ${isMarathi ? 'लावलेली झाडे' : 'Planted'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$targetTrees ${isMarathi ? 'ध्येय' : 'Goal'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 40),

                  // Leaderboard
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.rosette,
                        color: Colors.amber,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isMarathi
                            ? 'ग्रीन गार्डियन्स (लीडरबोर्ड)'
                            : 'Green Guardians (Top 5)',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      final int rank = index + 1;
                      final bool isTop3 = rank <= 3;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isTop3
                              ? Border.all(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  width: 2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isTop3
                                ? Colors.amber.shade100
                                : AppColors.primary.withValues(alpha: 0.1),
                            foregroundColor: isTop3
                                ? Colors.amber.shade700
                                : AppColors.primary,
                            radius: 22,
                            child: Text(
                              '#${user['rank']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          title: Text(
                            user['name'] as String,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.tree,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${user['trees']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 700 + (index * 100)),
                          )
                          .slideX();
                    },
                  ),

                  const SizedBox(height: 80), // Padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlantTreeScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(
          CupertinoIcons.leaf_arrow_circlepath,
          color: Colors.white,
        ),
        label: Text(
          isMarathi ? 'अभियानात सामील व्हा' : 'Plant for Abhiyan',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ).animate().scale(delay: 1000.ms),
    );
  }
}
