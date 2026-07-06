import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';

import 'package:firebase_core/firebase_core.dart';

import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  // Notification setup is non-critical — don't block startup if it fails
  try {
    await NotificationService().initialize();
    await NotificationService().scheduleDailyWateringReminders();
  } catch (e) {
    debugPrint('NotificationService init failed: $e');
  }

  runApp(const VasundharaApp());
}

class VasundharaApp extends StatelessWidget {
  const VasundharaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Vasundhara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
