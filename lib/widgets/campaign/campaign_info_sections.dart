import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class MissionSection extends StatelessWidget {
  final bool isMarathi;

  const MissionSection({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'आमचे ध्येय' : 'Our Mission',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(),
        const SizedBox(height: 10),
        Text(
          isMarathi
              ? 'हरित वसुंधरा अभियान हा आपल्या शहराला पुन्हा हिरवेगार बनवण्याचा एक उपक्रम आहे. एक झाड लावून हवामान बदलाशी लढण्यासाठी आमच्यात सामील व्हा.'
              : 'The Green Vasundhara Abhiyan is a community-driven initiative to restore our urban canopy. Join us in fighting climate change, one tree at a time.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(),
      ],
    );
  }
}

class WhyJoinSection extends StatelessWidget {
  final bool isMarathi;

  const WhyJoinSection({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'वसुंधरामध्ये का सामील व्हावे?' : 'Why Join Vasundhara?',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(),
        const SizedBox(height: 12),
        _BenefitItem(
          title:
              isMarathi ? '🌍 हवामान बदलाशी लढा' : '🌍 Combat Climate Change',
          description: isMarathi
              ? 'प्रत्येक झाड कार्बन डायऑक्साइड शोषून घेते आणि आपली हवा शुद्ध करते.'
              : 'Every tree absorbs CO2 and purifies our air.',
          delayMs: 350,
        ),
        _BenefitItem(
          title: isMarathi
              ? '📜 अधिकृत प्रमाणपत्रे मिळवा'
              : '📜 Earn Official Certificates',
          description: isMarathi
              ? 'तुमच्या योगदानासाठी आणि झाडांच्या वाढीसाठी प्रमाणपत्रे मिळवा.'
              : 'Get recognized for your planting and 6-month growth tracking.',
          delayMs: 400,
        ),
        _BenefitItem(
          title: isMarathi ? '🏆 लीडरबोर्डवर चढा' : '🏆 Climb the Leaderboard',
          description: isMarathi
              ? 'समाजातील इतर लोकांशी स्पर्धा करा आणि निसर्गाचे रक्षक बना.'
              : 'Compete with the community and become a top Green Guardian.',
          delayMs: 450,
        ),
        _BenefitItem(
          title: isMarathi
              ? '🌳 भविष्यातील पिढ्यांसाठी'
              : '🌳 For Future Generations',
          description: isMarathi
              ? 'आपल्या मुलांसाठी एक हिरवेगार आणि निरोगी जग तयार करा.'
              : 'Leave behind a greener, healthier world for our children.',
          delayMs: 500,
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;
  final int delayMs;

  const _BenefitItem({
    required this.title,
    required this.description,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideX(begin: 0.1);
  }
}

class SeedBallsInitiative extends StatelessWidget {
  final bool isMarathi;

  const SeedBallsInitiative({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/images/seed_balls.jpg',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isMarathi ? 'नवीन उपक्रम' : 'NEW INITIATIVE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isMarathi
                      ? 'सीड बॉल्स (बीजगोळे) मोहीम'
                      : 'The Seed Balls Campaign',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isMarathi
                      ? 'दुर्गम भागात झाडे लावण्यासाठी सीड बॉल्स हा एक सोपा आणि प्रभावी मार्ग आहे. माती आणि खताच्या गोळ्यात बिया सुरक्षित राहतात आणि पावसाळ्यात रुजतात. या पावसाळ्यात हजारो सीड बॉल्स फेकून डोंगर हिरवेगार करण्यासाठी आमच्यात सामील व्हा!'
                      : 'Seed balls are an ancient and incredibly effective method of reforestation in hard-to-reach areas. Encased in a mixture of clay and compost, seeds remain protected from predators until the monsoon rains trigger their germination. Join us this season in throwing thousands of seed balls to revive our barren hills!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
