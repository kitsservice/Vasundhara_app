import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';

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
          Container(
            padding:
                const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
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
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(CupertinoIcons.globe, color: AppColors.primary),
            title: Text(
              isMarathi
                  ? 'इंग्रजीत बदला (Switch to EN)'
                  : 'मराठीत बदला (Switch to MR)',
            ),
            onTap: context.read<SettingsProvider>().toggleLanguage,
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
