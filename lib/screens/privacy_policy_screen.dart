import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          isMarathi ? 'गोपनीयता धोरण' : 'Privacy Policy',
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
              isMarathi
                  ? 'शेवटचे अद्यतनित: २६ जून २०२६'
                  : 'Last Updated: June 26, 2026',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: isMarathi
                  ? '१. स्थान डेटा संकलन'
                  : '1. Location Data Collection',
              content: isMarathi
                  ? 'जेव्हा तुम्ही झाड लावता तेव्हाच हे ॲप तुमचे अचूक GPS स्थान संकलित करते. हे ग्लोबल ट्री मॅपवर तुमचे झाड अचूकपणे पिन करण्यासाठी केले जाते. आम्ही पार्श्वभूमीत तुमच्या स्थानाचा मागोवा घेत नाही.'
                  : 'This app collects your precise GPS location ONLY when you are actively submitting a tree plantation form. This is to accurately pin your tree on the Global Tree Map. We do NOT track your location in the background.',
            ),
            _buildSection(
              title: isMarathi
                  ? '२. कॅमेरा आणि फोटो प्रवेश'
                  : '2. Camera and Photo Access',
              content: isMarathi
                  ? 'झाडांची लागवड आणि ६ महिन्यांच्या वाढीच्या अद्यतनांची पडताळणी करण्यासाठी आम्हाला कॅमेरा किंवा गॅलरी प्रवेश आवश्यक आहे. तुम्ही जाणीवपूर्वक निवडलेले आणि अपलोड केलेले फोटोच आम्ही ॲक्सेस करतो. आम्ही तुमचे संपूर्ण फोटो लायब्ररी स्कॅन करत नाही.'
                  : 'We require camera or gallery access to verify tree plantations and track 6-month growth updates. We only access the specific photo you consciously choose and upload. We do NOT scan your entire photo library.',
            ),
            _buildSection(
              title: isMarathi
                  ? '३. वापरकर्ता खाती आणि प्रमाणीकरण'
                  : '3. User Accounts & Authentication',
              content: isMarathi
                  ? 'आम्ही सुरक्षिततेसाठी Firebase द्वारे तुमचे नाव आणि ईमेल पत्ता संकलित करतो. ग्रीन गार्डियन्स लीडरबोर्डवर तुमचे नाव आणि "एकूण लावलेली झाडे" स्कोर इतर वापरकर्त्यांना सार्वजनिकरित्या दृश्यमान असेल.'
                  : 'We collect your name and email address via Firebase for security. Your name and "Total Trees Planted" score will be publicly visible to other users on the Green Guardians Leaderboard.',
            ),
            _buildSection(
              title: isMarathi
                  ? '४. तृतीय-पक्ष सेवा प्रदाता'
                  : '4. Third-Party Service Providers',
              content: isMarathi
                  ? 'आम्ही डेटाबेस होस्टिंग आणि सुरक्षित प्रमाणीकरणासाठी Google Firebase वापरतो आणि GPS कोऑर्डिनेट्स वाचनीय पत्त्यांमध्ये रूपांतरित करण्यासाठी OpenStreetMap (OSM) वापरतो.'
                  : 'We utilize Google Firebase for database hosting and secure authentication, and OpenStreetMap (OSM) for converting GPS coordinates into readable addresses.',
            ),
            _buildSection(
              title: isMarathi
                  ? '५. डेटा हटवण्याचे धोरण'
                  : '5. Data Deletion Policy',
              content: isMarathi
                  ? 'तुमचा हक्क आहे की तुम्ही कधीही तुमचे खाते, तुमचे GPS कोऑर्डिनेट्स आणि तुमचे झाडांचे फोटो आमच्या सर्व्हरवरून हटवण्याची विनंती करू शकता. यासाठी आमच्या सपोर्ट टीमशी संपर्क साधा.'
                  : 'You have the right to request the complete deletion of your account, your GPS coordinates, and your tree photos from our servers at any time by contacting our support team.',
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
