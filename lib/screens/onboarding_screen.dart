import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import 'auth_wrapper.dart';

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
          'title': isMarathi
              ? 'अधिक झाडे लावा, उत्तम जीवन जगा'
              : 'Plant More, Live Better',
          'subtitle': isMarathi
              ? 'चला आपल्या पृथ्वीचा प्रत्येक कोपरा हिरवागार आणि सुंदर बनवूया.'
              : "Let's make every corner of our earth green and beautiful.",
          'image': 'assets/images/onboarding_1.png',
          'button': isMarathi ? 'सुरु करा' : 'Get Started',
        },
        {
          'title': isMarathi
              ? 'वसुंधरा मध्ये आपले स्वागत आहे'
              : 'Welcome to Vasundhara',
          'subtitle': isMarathi
              ? 'एकत्रितपणे आपण एक हरित ग्रह बनवू शकतो.'
              : 'Together we can make a greener planet.',
          'image': 'assets/images/onboarding_2.png',
          'button': isMarathi ? 'पुढे' : 'Next',
        },
        {
          'title': isMarathi
              ? 'तुमच्या हरित प्रभावाचा मागोवा घ्या'
              : 'Track Your Green Impact',
          'subtitle': isMarathi
              ? 'तुम्ही लावलेल्या झाडांचे आणि त्यांच्या वाढीचे निरीक्षण करा.'
              : 'Monitor your planted trees and their growth.',
          'image': 'assets/images/onboarding_3.png',
          'button': isMarathi ? 'पुढे' : 'Next',
        },
        {
          'title':
              isMarathi ? 'निसर्गासाठी शपथ घ्या' : 'Take a Pledge for Nature',
          'subtitle': isMarathi
              ? 'आजच शपथ घ्या आणि इतरांनाही तसे करण्यास प्रेरित करा.'
              : 'Pledge today and inspire others to do the same.',
          'image': 'assets/images/onboarding_4.png',
          'button': isMarathi ? 'आता सुरु करा' : 'Start Now',
        },
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.watch<SettingsProvider>().isMarathi;
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

          // Language Toggle Top Right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      context.read<SettingsProvider>().toggleLanguage();
                    });
                  },
                  icon: const Icon(
                    CupertinoIcons.globe,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    isMarathi ? 'EN' : 'MR',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == getOnboardingData(isMarathi).length - 1;
              });
            },
            itemCount: getOnboardingData(isMarathi).length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 0) ...[
                      const Text(
                        'Vasundhara',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isMarathi ? 'वृक्षारोपण' : 'Tree Plantation',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      const SizedBox(height: 80),
                    ],
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        getOnboardingData(isMarathi)[index]['image']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            getOnboardingData(isMarathi)[index]['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            getOnboardingData(isMarathi)[index]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
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
                          ? (isMarathi ? 'सुरु करा' : 'Get Started')
                          : (isMarathi ? 'पुढे' : 'Next'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isLastPage) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _goToHome,
                    child: Text(
                      isMarathi ? 'वगळा' : 'Skip',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
