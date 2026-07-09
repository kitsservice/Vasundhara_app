// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/auth/login_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll("'Welcome Back'", "'ui_key_204'.tr()");
  content = content.replaceAll("'Login to continue your green journey.'", "'ui_key_205'.tr()");
  content = content.replaceAll("labelText: 'Email Address'", "labelText: 'ui_key_206'.tr()");
  content = content.replaceAll("labelText: 'Password'", "labelText: 'ui_key_208'.tr()");
  // Forgot password
  content = content.replaceAll("'Forgot Password?'", "'ui_key_210'.tr()");
  content = content.replaceAll("'Login'", "'ui_key_211'.tr()");
  content = content.replaceAll("'OR'", "'ui_key_212'.tr()");
  content = content.replaceAll("'Continue with Google'", "'ui_key_213'.tr()");
  content = content.replaceAll("\"Don't have an account?\"", "'ui_key_214'.tr()");
  content = content.replaceAll("'Sign Up'", "'ui_key_215'.tr()");

  // Fix any const Text( issues created by this
  content = content.replaceAll('const Text(', 'Text(');

  file.writeAsStringSync(content);
  print('Fixed translations in login_screen.dart');
}
