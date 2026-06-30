import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_wrapper.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Allow enough time for the full tree growing animation
    Future.delayed(const Duration(milliseconds: 3800), () async {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (mounted) {
        if (isFirstLaunch) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Proper Tree Growing Animation
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Phase 3: The fully grown tree
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(Icons.park, size: 120, color: Colors.white),
                  )
                      .animate(delay: 1500.ms)
                      .scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                        begin: const Offset(0, 0),
                      )
                      .then()
                      .shake(hz: 3, duration: 500.ms) // slight rustle of leaves
                      .then()
                      .shimmer(
                        duration: 1000.ms,
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),

                  // Phase 2: The sprout that appears first, then grows up and disappears
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child:
                        Icon(Icons.eco, size: 60, color: AppColors.secondary),
                  )
                      .animate(delay: 700.ms)
                      .scale(
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                        begin: const Offset(0, 0),
                      )
                      .then(delay: 300.ms)
                      .slideY(end: -0.5, duration: 300.ms) // grows upward
                      .fade(
                        end: 0,
                        duration: 300.ms,
                      ) // disappears into the big tree
                      .scale(end: const Offset(1.5, 1.5), duration: 300.ms),

                  // Phase 1: The seed dropping into the ground
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B4513), // Saddle brown seed
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: -8,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.bounceOut,
                      )
                      .then(delay: 200.ms)
                      .scale(
                        duration: 300.ms,
                        end: const Offset(0, 0),
                      ), // seed sinks in
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Vasundhara',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
            ).animate().fade(delay: 1800.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 10),
            Text(
              'Plant a tree, plant a hope.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                  ),
            ).animate().fade(delay: 2400.ms),
          ],
        ),
      ),
    );
  }
}
