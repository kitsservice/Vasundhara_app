import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../screens/core/profile_screen.dart';
import '../screens/gamification/certificates_screen.dart';

class ProfessionalDrawer extends StatelessWidget {
  const ProfessionalDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              (isMarathi ? 'वसुंधरा' : 'Vasundhara'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ??
                              (isMarathi ? 'पृथ्वी रक्षक' : 'Earth Guardian'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.globe,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMarathi ? 'ॲपची भाषा' : 'App Language',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isMarathi ? 'मराठी' : 'English',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: isMarathi,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) {
                      context.read<SettingsProvider>().toggleLanguage();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              CupertinoIcons.doc_text,
              color: AppColors.primary,
            ),
            title: Text(
              isMarathi ? 'माझी प्रमाणपत्रे' : 'My Certificates',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificatesScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(
              CupertinoIcons.square_arrow_right,
              color: AppColors.error,
            ),
            title: Text(
              isMarathi ? 'बाहेर पडा' : 'Logout',
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () {
              // Note: AuthWrapper will automatically redirect after this
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
