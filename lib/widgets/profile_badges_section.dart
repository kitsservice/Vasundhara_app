import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hasPhilanthropist = context.select<UserProvider, bool>(
      (provider) => provider.unlockedBadges.contains('green_philanthropist'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'ui_key_172'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasPhilanthropist
                        ? [
                            const Color(0xFFFFD700),
                            const Color(0xFFF57F17),
                          ] // Shiny Gold
                        : [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ], // Locked Grey
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: hasPhilanthropist
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  CupertinoIcons.heart_solid,
                  color:
                      hasPhilanthropist ? Colors.white : Colors.grey.shade500,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Green Philanthropist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasPhilanthropist
                            ? AppColors.textPrimary
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPhilanthropist
                          ? ('ui_key_173'.tr())
                          : ('ui_key_174'.tr()),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            hasPhilanthropist ? AppColors.success : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasPhilanthropist)
                Icon(CupertinoIcons.lock_fill, color: Colors.grey.shade400),
            ],
          ),
        ),
      ],
    );
  }
}
