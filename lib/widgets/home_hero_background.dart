import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../screens/core/plant_tree_screen.dart';
import '../providers/user_provider.dart';

class HomeHeroBackground extends StatelessWidget {
  const HomeHeroBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
    final userProvider = context.watch<UserProvider>();

    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hero Background Image with Gradient Overlay
          Stack(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/home_hero_plant.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              // Gradient Overlay to ensure text readability
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.8],
                  ),
                ),
              ),
            ],
          ),

          // Hero Text
          Positioned(
            top: 40,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMarathi
                      ? 'आज लावा,\nउद्या सुरक्षित करा'
                      : 'Plant Today,\nProtect Tomorrow',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 280,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      children: isMarathi
                          ? [
                              const TextSpan(
                                text:
                                    'या चळवळीत सामील व्हा. अधिक झाडे लावा आणि आपल्या ग्रहाला ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF047857),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'हिरवेगार बनवा.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          : [
                              const TextSpan(
                                text:
                                    'Join the movement. Plant more trees and make our ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF047857),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'planet greener.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ).animate().fade(duration: 600.ms).slideY(begin: -0.2),
          ),

          // Floating Stats Card
          Container(
            margin: const EdgeInsets.only(top: 280, left: 24, right: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.eco,
                      value: userProvider.totalTreesPlanted.toString(),
                      label: isMarathi ? 'झाडे लावली' : 'Trees Planted',
                      iconColor: const Color(0xFF10B981),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _StatItem(
                      icon: Icons.park,
                      value: userProvider.totalTreesSurvived.toString(),
                      label: isMarathi ? 'झाडे जगली' : 'Trees Survived',
                      iconColor: const Color(0xFF047857),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    _StatItem(
                      icon: CupertinoIcons.location_solid,
                      value: userProvider.totalLocations.toString(),
                      label: isMarathi ? 'ठिकाणे' : 'Locations',
                      iconColor: const Color(0xFF6B7280),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlantTreeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      CupertinoIcons.leaf_arrow_circlepath,
                      color: Colors.white,
                    ),
                    label: Text(
                      isMarathi ? 'झाड लावा' : 'Plant a Tree',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Deep Forest
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
