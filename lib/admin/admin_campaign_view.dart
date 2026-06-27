import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class AdminCampaignView extends StatelessWidget {
  const AdminCampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController =
        TextEditingController(text: 'Green Vasundhara Abhiyan');
    final targetController = TextEditingController(text: '50000');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Manager',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Control the global mission target and active drives.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.flag_fill,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Live Campaign Configuration',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title Field
                Text(
                  'Campaign Title',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.textformat,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Target Field
                Text(
                  'Global Tree Target',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.number,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Campaign Updated Successfully!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Deploy Update Globally',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
