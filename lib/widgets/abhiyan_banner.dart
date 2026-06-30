import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../screens/core/campaign_hub_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AbhiyanBannerWidget extends StatelessWidget {
  const AbhiyanBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary, // Extremely Deep Forest Green
            AppColors.secondary, // Rich Emerald
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMarathi
                      ? 'हरित वसुंधरा अभियानात सामील व्हा'
                      : 'Join the Green Vasundhara Abhiyan',
                  style: GoogleFonts.outfit(
                    fontSize: 20, // Slightly larger
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isMarathi
                      ? 'हवामान बदलाशी लढा, प्रमाणपत्रे मिळवा आणि लीडरबोर्डवर चढा!'
                      : 'Combat climate change, earn official certificates, and climb the leaderboard!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CampaignHubScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent, // Premium Gold
                    foregroundColor: AppColors.primary, // Dark Text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.accent.withValues(alpha: 0.5),
                    minimumSize: const Size(120, 40),
                  ),
                  child: Text(
                    isMarathi ? 'अधिक जाणून घ्या' : 'Know More',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800, // Extra bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/images/realistic_plant.png',
              fit: BoxFit.contain,
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: -6,
                  end: 6,
                  duration: 2000.ms,
                  curve: Curves.easeInOutSine,
                ),
          ),
        ],
      ),
    );
  }
}
