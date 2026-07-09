import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import 'profile_stat.dart';
import 'profile_avatar_widget.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final totalTreesPlanted = userProvider.totalTreesPlanted;
    final badgesEarned =
        userProvider.unlockedBadges.length + (totalTreesPlanted / 10).floor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
            FirebaseAuth.instance.currentUser?.displayName ?? 'Eco Guardian',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? 'Joined June 2026',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfileStat(
                title: 'Trees Planted',
                value: '$totalTreesPlanted',
                icon: Icons.eco,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              ProfileStat(
                title: 'Badges',
                value: '$badgesEarned',
                icon: CupertinoIcons.rosette,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
