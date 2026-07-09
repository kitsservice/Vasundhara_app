import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ui_key_120'.tr(),
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ui_key_121'.tr(),
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'ui_key_122'.tr(),
              content: 'ui_key_123'.tr(),
            ),
            _buildSection(
              title: 'ui_key_124'.tr(),
              content: 'ui_key_125'.tr(),
            ),
            _buildSection(
              title: 'ui_key_126'.tr(),
              content: 'ui_key_127'.tr(),
            ),
            _buildSection(
              title: 'ui_key_128'.tr(),
              content: 'ui_key_129'.tr(),
            ),
            _buildSection(
              title: 'ui_key_130'.tr(),
              content: 'ui_key_131'.tr(),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 Vasundhara App',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
