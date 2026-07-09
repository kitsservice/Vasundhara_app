import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@vasundhara.app',
      query: 'subject=Bug Report - Vasundhara App',
    );
    try {
      if (!await launchUrl(emailLaunchUri)) {
        debugPrint('Could not launch email');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

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
          'ui_key_106'.tr(),
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
            // Contact Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.mail,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ui_key_107'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'support@vasundhara.app',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchEmail,
                      icon: const Icon(
                        CupertinoIcons.ant,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'ui_key_108'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ui_key_109'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _FaqTile(
              question: 'ui_key_110'.tr(),
              answer: 'ui_key_111'.tr(),
            ),
            _FaqTile(
              question: 'ui_key_112'.tr(),
              answer: 'ui_key_113'.tr(),
            ),
            _FaqTile(
              question: 'ui_key_114'.tr(),
              answer: 'ui_key_115'.tr(),
            ),
            _FaqTile(
              question: 'ui_key_116'.tr(),
              answer: 'ui_key_117'.tr(),
            ),
            _FaqTile(
              question: 'ui_key_118'.tr(),
              answer: 'ui_key_119'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          _isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
          size: 20,
          color: AppColors.primary,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              widget.answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
