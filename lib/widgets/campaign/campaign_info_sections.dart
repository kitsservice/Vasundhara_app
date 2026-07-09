import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
          'ui_key_139'.tr(),
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(),
        const SizedBox(height: 10),
        Text(
          'ui_key_140'.tr(),
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
          'ui_key_141'.tr(),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(),
        const SizedBox(height: 12),
        _BenefitItem(
          title:
              'ui_key_142'.tr(),
          description: 'ui_key_143'.tr(),
          delayMs: 350,
        ),
        _BenefitItem(
          title: 'ui_key_144'.tr(),
          description: 'ui_key_145'.tr(),
          delayMs: 400,
        ),
        _BenefitItem(
          title: 'ui_key_146'.tr(),
          description: 'ui_key_147'.tr(),
          delayMs: 450,
        ),
        _BenefitItem(
          title: 'ui_key_148'.tr(),
          description: 'ui_key_149'.tr(),
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
                    'ui_key_150'.tr(),
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
                  'ui_key_151'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ui_key_152'.tr(),
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

class GreenEarthInfoSection extends StatelessWidget {
  final bool isMarathi;

  const GreenEarthInfoSection({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF047857).withValues(alpha: 0.1),
            const Color(0xFF10B981).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.leaf_arrow_circlepath,
                  color: Color(0xFF047857),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMarathi ? 'हरित पृथ्वी माहिती' : 'Green Earth Information',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isMarathi
                ? 'आमचा हरित पृथ्वी उपक्रम स्थानिक समुदायांना शाश्वत पद्धती आणण्यावर लक्ष केंद्रित करतो. शहरी भागांचे हिरव्यागार जागेत रूपांतर करण्यासाठी आम्ही संसाधने आणि समर्थन प्रदान करतो. जैवविविधतेला चालना देऊन, आपण आपल्या ग्रहाला बरे करण्याच्या दिशेने एक महत्त्वपूर्ण पाऊल उचलतो.'
                : 'The Green Earth Initiative focuses on bringing sustainable practices to local communities. We provide resources, guidance, and support to transform urban areas into lush, green spaces. By actively reducing our carbon footprint and promoting biodiversity, we take a significant step towards healing our planet.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _InfoPoint(
            text: isMarathi
                ? 'परिसंस्थेचा समतोल राखण्यासाठी देशी झाडे लावणे.'
                : 'Planting native trees to restore ecological balance.',
          ),
          _InfoPoint(
            text: isMarathi
                ? 'शाश्वत जीवनाविषयी समुदायांना शिक्षित करणे.'
                : 'Educating communities on sustainable living.',
          ),
          _InfoPoint(
            text: isMarathi
                ? 'शहरी वन्यजीवांसाठी हिरवे पट्टे तयार करणे.'
                : 'Creating green corridors for urban wildlife.',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }
}

class _InfoPoint extends StatelessWidget {
  final String text;

  const _InfoPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              CupertinoIcons.circle_fill,
              size: 8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VasundharaAbhiyanInfoSection extends StatelessWidget {
  final bool isMarathi;

  const VasundharaAbhiyanInfoSection({super.key, required this.isMarathi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.tree,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMarathi ? 'वसुंधरा अभियानाबद्दल' : 'About Vasundhara Abhiyan',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isMarathi
                ? 'हरित वसुंधरा अभियान ही एक जनचळवळ आहे जिचे उद्दिष्ट पृथ्वीचे हरित आवरण वाढवणे आणि हवामान बदलाचा सामना करणे आहे. या मोहिमेद्वारे लाखो झाडे लावण्याचा आमचा संकल्प आहे.'
                : 'The Green Vasundhara Abhiyan is a mass movement aimed at restoring the Earth\'s green cover and combating climate change. Through this initiative, we are determined to plant millions of trees worldwide.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(
            icon: Icons.public,
            title: isMarathi ? 'जागतिक दृष्टी' : 'Global Vision',
            desc: isMarathi ? 'हरित आणि शाश्वत भविष्य.' : 'A greener and sustainable future.',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.groups,
            title: isMarathi ? 'जनसहभाग' : 'Citizen Participation',
            desc: isMarathi ? 'समुदायांना एकत्र आणणे.' : 'Bringing communities together.',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.eco,
            title: isMarathi ? 'जैवविविधता' : 'Biodiversity',
            desc: isMarathi ? 'स्थानिक वनस्पती आणि प्राण्यांचे संरक्षण.' : 'Protecting native flora and fauna.',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1);
  }

  Widget _buildStatRow({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
