import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class AdminModerationView extends StatelessWidget {
  const AdminModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moderation Queue',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Review recent tree uploads to maintain data integrity.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            itemCount: 3, // Mock pending photos
            itemBuilder: (context, index) {
              return _ModerationCard(index: index)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 200 + (index * 150)))
                  .slideY(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }
}

class _ModerationCard extends StatelessWidget {
  final int index;
  const _ModerationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Placeholder with gradient overlay
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade900,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.tree,
                        size: 80,
                        color: Colors.white24,
                      ),
                      // Mock nature background color
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priya Patel',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pune, Maharashtra',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tree Rejected and removed.'),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.redAccent.shade100,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tree Approved! Added to Map.'),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
