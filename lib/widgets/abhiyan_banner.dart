import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../screens/core/campaign_hub_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AbhiyanBannerWidget extends StatefulWidget {
  const AbhiyanBannerWidget({super.key});

  @override
  State<AbhiyanBannerWidget> createState() => _AbhiyanBannerWidgetState();
}

class _AbhiyanBannerWidgetState extends State<AbhiyanBannerWidget> {
  late Stream<DocumentSnapshot> _campaignStream;

  @override
  void initState() {
    super.initState();
    _campaignStream = FirebaseFirestore.instance
        .collection('admin')
        .doc('campaign')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _campaignStream,
      builder: (context, snapshot) {
        String programType = 'Tree Plantation';
        String customTitle = '';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          programType = data?['programType'] ?? 'Tree Plantation';
          customTitle = data?['title'] ?? '';
        }

        String displayTitle = '';
        String displaySubtitle = '';
        List<Color> gradientColors = [AppColors.primary, AppColors.secondary];
        Widget graphic = Image.asset(
          'assets/images/realistic_plant.png',
          fit: BoxFit.contain,
          cacheWidth: 800,
        );

        if (programType == 'Facilitation Program') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_132'.tr());
          displaySubtitle = 'ui_key_133'.tr();
          gradientColors = [Colors.blue.shade800, Colors.blue.shade500];
          graphic = const Icon(
            CupertinoIcons.group_solid,
            size: 100,
            color: Colors.white70,
          );
        } else if (programType == 'Awareness Drive') {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_134'.tr());
          displaySubtitle = 'ui_key_135'.tr();
          gradientColors = [Colors.orange.shade800, Colors.orange.shade500];
          graphic = const Icon(
            CupertinoIcons.speaker_3_fill,
            size: 100,
            color: Colors.white70,
          );
        } else {
          displayTitle = customTitle.isNotEmpty
              ? customTitle
              : ('ui_key_136'.tr());
          displaySubtitle = 'ui_key_137'.tr();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gradientColors[1].withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.25),
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
                      displayTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displaySubtitle,
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
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.accent.withValues(alpha: 0.5),
                        minimumSize: const Size(120, 40),
                      ),
                      child: Text(
                        'ui_key_138'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: programType == 'Tree Plantation'
                      ? graphic
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .moveY(
                            begin: -6,
                            end: 6,
                            duration: 2000.ms,
                            curve: Curves.easeInOutSine,
                          )
                      : graphic.animate().scale(
                            delay: 200.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
