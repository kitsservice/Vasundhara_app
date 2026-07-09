// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/auth/login_screen.dart');
  String content = file.readAsStringSync();

  // Add import if missing
  if (!content.contains('easy_localization.dart')) {
    content = content.replaceFirst(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport 'package:easy_localization/easy_localization.dart';",
    );
  }

  // Replace text
  content = content.replaceFirst("const Text('Please fill in all fields.')", "Text('ui_key_216'.tr())");
  content = content.replaceFirst("const Text(\n                'Welcome Back',", "Text(\n                'ui_key_204'.tr(),");
  content = content.replaceFirst("'Login to continue your green journey.'", "'ui_key_205'.tr()");
  content = content.replaceFirst("const Text(\n                'Email',", "Text(\n                'ui_key_206'.tr(),");
  content = content.replaceFirst("hintText: 'Enter your email',", "hintText: 'ui_key_207'.tr(),");
  content = content.replaceFirst("const Text(\n                'Password',", "Text(\n                'ui_key_208'.tr(),");
  content = content.replaceFirst("hintText: 'Enter your password',", "hintText: 'ui_key_209'.tr(),");
  content = content.replaceFirst("const Text(\n                    'Forgot Password?',", "Text(\n                    'ui_key_210'.tr(),");
  
  // Login Button foreground color and text
  content = content.replaceFirst(
    'backgroundColor: AppColors.primary,', 
    'backgroundColor: AppColors.primary,\n                        foregroundColor: Colors.white,',
  );
  content = content.replaceFirst("const Text(\n                              'Login',", "Text(\n                              'ui_key_211'.tr(),");

  // OR text
  content = content.replaceFirst("const Text(\n                      'OR',", "Text(\n                      'ui_key_212'.tr(),");
  
  // Continue with Google
  content = content.replaceFirst("const Text(\n                        'Continue with Google',", "Text(\n                        'ui_key_213'.tr(),");

  // Don't have an account?
  content = content.replaceFirst("const Text(\n                    \"Don't have an account?\",", "Text(\n                    'ui_key_214'.tr(),");

  // Sign up
  content = content.replaceFirst("const Text(\n                      'Sign up',", "Text(\n                      'ui_key_215'.tr(),");

  file.writeAsStringSync(content);
  print('Updated login_screen.dart');
}
