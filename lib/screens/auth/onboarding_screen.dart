import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import 'auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  List<Map<String, String>> getOnboardingData(bool isMarathi) => [
        {
          'title': 'ui_key_1'.tr(),
          'subtitle': isMarathi
              ? 'चला आपल्या पृथ्वीचा प्रत्येक कोपरा हिरवागार आणि सुंदर बनवूया.'
              : "Let's make every corner of our earth green and beautiful.",
          'image': 'assets/images/onboarding_1.png',
          'button': 'ui_key_2'.tr(),
        },
        {
          'title': 'ui_key_3'.tr(),
          'subtitle': 'ui_key_4'.tr(),
          'image': 'assets/images/onboarding_2.png',
          'button': 'ui_key_5'.tr(),
        },
        {
          'title': 'ui_key_6'.tr(),
          'subtitle': 'ui_key_7'.tr(),
          'image': 'assets/images/onboarding_3.png',
          'button': 'ui_key_8'.tr(),
        },
        {
          'title':
              'ui_key_9'.tr(),
          'subtitle': 'ui_key_10'.tr(),
          'image': 'assets/images/onboarding_4.png',
          'button': 'ui_key_11'.tr(),
        },
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft decor
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Header & Language Toggle
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vasundhara',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'ui_key_12'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final code = context.locale.languageCode;
if (code == 'en') {
  context.setLocale(const Locale('mr'));
} else if (code == 'mr') {
  context.setLocale(const Locale('hi'));
} else {
  context.setLocale(const Locale('en'));
}

                        },
                        icon: const Icon(
                          CupertinoIcons.globe,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          context.locale.languageCode.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Pager
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        isLastPage =
                            index == getOnboardingData(isMarathi).length - 1;
                      });
                    },
                    itemCount: getOnboardingData(isMarathi).length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),
                            // Image takes up most of the space
                            Expanded(
                              flex: 5,
                              child: Image.asset(
                                getOnboardingData(isMarathi)[index]['image']!,
                                fit: BoxFit.contain,
                                cacheWidth: 800,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Text Section
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Text(
                                    getOnboardingData(isMarathi)[index]
                                        ['title']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    getOnboardingData(isMarathi)[index]
                                        ['subtitle']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls Area
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: getOnboardingData(isMarathi).length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: AppColors.primary,
                          dotColor: Color(0xFFE5E7EB),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              _goToHome();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage
                                ? ('ui_key_14'.tr())
                                : ('ui_key_15'.tr()),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Reserve fixed space for Skip button so layout doesn't jump on the last page
                      SizedBox(
                        height: 48,
                        child: !isLastPage
                            ? TextButton(
                                onPressed: _goToHome,
                                child: Text(
                                  'ui_key_16'.tr(),
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
