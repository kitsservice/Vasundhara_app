import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth_provider.dart';
import '../settings/privacy_policy_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/notifications_screen.dart';
import '../settings/about_us_screen.dart';
import '../gamification/certificates_list_screen.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/profile_info_card.dart';
import '../../widgets/profile_badges_section.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'ui_key_200'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const ProfileInfoCard(),
            const SizedBox(height: 24),

            // Gamification Badges Section
            const ProfileBadgesSection(),
            const SizedBox(height: 24),

            // Certificates
            SettingsTile(
              icon: CupertinoIcons.rosette,
              title: 'ui_key_170'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CertificatesListScreen(),
                  ),
                );
              },
            ),



            // Settings List
            SettingsTile(
              icon: CupertinoIcons.bell,
              title: 'ui_key_46'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: CupertinoIcons.globe,
              title: 'ui_key_201'.tr(),
              onTap: () {
                _showLanguageBottomSheet(context);
              },
            ),
            SettingsTile(
              icon: CupertinoIcons.lock_shield,
              title: 'ui_key_120'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: CupertinoIcons.question_circle,
              title: 'ui_key_106'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: CupertinoIcons.info_circle,
              title: 'About Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            
            // Share App
            SettingsTile(
              icon: CupertinoIcons.share,
              title: context.locale.languageCode == 'mr' ? 'अॅप शेअर करा' : 'Share App',
              onTap: () {
                // ignore: deprecated_member_use
                Share.share('Join me in making the Earth greener with the Vasundhara app! Download now: https://vasundhara.app');
              },
            ),
            
            const SizedBox(height: 16),
            SettingsTile(
              icon: CupertinoIcons.square_arrow_right,
              title: 'ui_key_171'.tr(),
              isDestructive: true,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.locale.languageCode == 'mr' ? 'बाहेर पडा' : 'Log Out',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.locale.languageCode == 'mr'
              ? 'तुम्हाला नक्की बाहेर पडायचे आहे का?'
              : 'Are you sure you want to log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.locale.languageCode == 'mr' ? 'नाही' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.locale.languageCode == 'mr' ? 'होय, बाहेर पडा' : 'Log Out',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final currentLocale = context.locale.languageCode;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ui_key_202'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 24),
              _buildLanguageOption(
                context,
                title: 'ui_key_203'.tr(),
                languageCode: 'en',
                isSelected: currentLocale == 'en',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                title: 'मराठी (Marathi)',
                languageCode: 'mr',
                isSelected: currentLocale == 'mr',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                title: 'हिन्दी (Hindi)',
                languageCode: 'hi',
                isSelected: currentLocale == 'hi',
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String languageCode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.setLocale(Locale(languageCode));
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green.shade500 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green.shade800 : Colors.grey.shade800,
              ),
            ),
            if (isSelected)
              const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
