import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      final photoURL = snapshot.data?.photoURL;
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          image: photoURL != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(photoURL),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: photoURL == null
                            ? const Icon(Icons.person, color: Colors.white, size: 32)
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              ('ui_key_168'.tr()),
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
                              ('ui_key_169'.tr()),
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

          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              CupertinoIcons.doc_text,
              color: AppColors.primary,
            ),
            title: Text(
              'ui_key_170'.tr(),
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
              'ui_key_171'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
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
}
