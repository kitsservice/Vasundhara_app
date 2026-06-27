import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/cloudinary_service.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'certificates_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final totalTreesPlanted = userProvider.totalTreesPlanted;
    final badgesEarned = (totalTreesPlanted / 10).floor();

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
            // User Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const ProfileAvatarWidget(),
                  const SizedBox(height: 16),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ??
                        'Eco Guardian',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ??
                        'Joined June 2026',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(
                        title: 'Trees Planted',
                        value: '$totalTreesPlanted',
                        icon: Icons.eco,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _ProfileStat(
                        title: 'Badges',
                        value: '$badgesEarned',
                        icon: CupertinoIcons.rosette,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Certificates
            _SettingsTile(
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
            _SettingsTile(
              icon: CupertinoIcons.bell,
              title: 'Notifications',
              onTap: () {},
            ),
            _SettingsTile(
              icon: CupertinoIcons.globe,
              title: 'Language (भाषा)',
              onTap: () {},
            ),
            _SettingsTile(
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
            _SettingsTile(
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
            _SettingsTile(
              icon: CupertinoIcons.square_arrow_right,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.red : AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ProfileAvatarWidget extends StatefulWidget {
  const ProfileAvatarWidget({super.key});

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);

      final String? url = await CloudinaryService.uploadImage(File(image.path));

      if (url != null) {
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
        // Force a rebuild of the auth state or just this widget
        setState(() {});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            backgroundImage:
                photoURL != null ? CachedNetworkImageProvider(photoURL) : null,
            child: photoURL == null
                ? const Icon(
                    CupertinoIcons.person_solid,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          if (_isUploading)
            const CircularProgressIndicator(color: Colors.white),
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.camera_fill,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
