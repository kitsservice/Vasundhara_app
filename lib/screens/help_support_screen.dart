import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';

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
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

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
          isMarathi ? 'मदत आणि समर्थन' : 'Help & Support',
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
                    isMarathi ? 'आम्हाला संपर्क करा' : 'Contact Us',
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
                        isMarathi ? 'बग नोंदवा' : 'Report an Issue',
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
              isMarathi
                  ? 'सतत विचारले जाणारे प्रश्न (FAQ)'
                  : 'Frequently Asked Questions',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _FaqTile(
              question: isMarathi
                  ? 'मी ॲप वापरून झाड कसे लावू शकतो?'
                  : 'How do I log a planted tree?',
              answer: isMarathi
                  ? 'नकाशावर किंवा कँपेन हबवर "Plant for Abhiyan" बटणावर क्लिक करा. तुमचे GPS चालू असल्याची खात्री करा आणि तुमच्या झाडाचा फोटो अपलोड करा.'
                  : 'Click the "Plant for Abhiyan" Floating Action Button on the map or campaign hub. Ensure GPS is on, and upload a photo.',
            ),
            _FaqTile(
              question: isMarathi
                  ? 'ॲप माझे स्थान का घेत नाही?'
                  : 'Why isn\'t the app fetching my location?',
              answer: isMarathi
                  ? 'तुमच्या फोनचे GPS चालू असल्याची खात्री करा आणि तुम्ही तुमच्या फोन सेटिंग्जमध्ये ॲपला स्थान (Location) परवानग्या दिल्या आहेत.'
                  : 'Ensure your phone\'s GPS is turned on and you have granted the app Location permissions in your phone settings.',
            ),
            _FaqTile(
              question: isMarathi
                  ? '६ महिन्यांचे अद्यतन काय आहे?'
                  : 'What is the 6-Month Growth Update?',
              answer: isMarathi
                  ? 'झाडांचे अस्तित्व सुनिश्चित करण्यासाठी, आम्ही वापरकर्त्यांना लागवडीच्या ६ महिन्यांनंतर त्यांच्या झाडाचा दुसरा फोटो अपलोड करण्यास सांगतो.'
                  : 'To ensure the survival of trees, we ask users to upload a second photo of their tree 6 months after planting.',
            ),
            _FaqTile(
              question: isMarathi
                  ? 'मी ग्रीन गार्डियन्स लीडरबोर्डवर कसा येऊ शकेन?'
                  : 'How do I get on the Green Guardians Leaderboard?',
              answer: isMarathi
                  ? 'अधिक झाडे लावा! लीडरबोर्ड जागतिक स्तरावर शीर्ष योगदानकर्त्यांचा मागोवा घेतो.'
                  : 'Plant more trees! The leaderboard tracks the top contributors globally.',
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
