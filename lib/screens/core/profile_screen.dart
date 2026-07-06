import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/privacy_policy_screen.dart';
import '../settings/help_support_screen.dart';
import '../gamification/certificates_list_screen.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/profile_info_card.dart';
import '../../widgets/profile_badges_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
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
              title: 'My Certificates',
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
              title: 'Notifications',
              onTap: () {},
            ),
            SettingsTile(
              icon: CupertinoIcons.globe,
              title: 'Language (भाषा)',
              onTap: () {},
            ),
            SettingsTile(
              icon: CupertinoIcons.lock_shield,
              title: 'Privacy Policy',
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
              title: 'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SettingsTile(
              icon: CupertinoIcons.square_arrow_right,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                context.read<AuthProvider>().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
