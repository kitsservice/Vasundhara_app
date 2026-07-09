import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../screens/gamification/leaderboard_screen.dart';

class ProgressSection extends StatelessWidget {
  final bool isMarathi;

  const ProgressSection({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('planted_trees').snapshots(),
      builder: (context, snapshot) {
        int currentTrees = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            currentTrees += (data['quantity'] as num?)?.toInt() ?? 1;
          }
        }

        // Dynamically set the next target goal based on current trees
        int targetTrees = 1000;
        if (currentTrees >= 1000) targetTrees = 5000;
        if (currentTrees >= 5000) targetTrees = 10000;
        if (currentTrees >= 10000) targetTrees = 50000;
        if (currentTrees >= 50000) targetTrees = 100000;

        double progress = currentTrees / targetTrees;
        if (progress > 1.0) progress = 1.0;

        return Container(
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
                  Row(
                    children: [
                      Text(
                        'ui_key_154'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.rosette,
                          color: Colors.amber,
                        ),
                        tooltip: 'View Leaderboard',
                      ),
                    ],
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
                    '$currentTrees ${'ui_key_155'.tr()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$targetTrees ${'ui_key_156'.tr()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
      },
    );
  }
}
