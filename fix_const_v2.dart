// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/auth/login_screen.dart');
  var content = file.readAsStringSync();
  
  // Remove const from InputDecoration
  content = content.replaceAll('const InputDecoration(', 'InputDecoration(');
  
  // Remove const from Padding (for the 'OR' divider)
  content = content.replaceAll('const Padding(\n                    padding: EdgeInsets.symmetric(horizontal: 16),\n                    child: Text(\n                      \'ui_key_212\'.tr(),', 
                               'Padding(\n                    padding: EdgeInsets.symmetric(horizontal: 16),\n                    child: Text(\n                      \'ui_key_212\'.tr(),',);
  // Just in case, simpler replace:
  content = content.replaceAll('const Padding(', 'Padding(');

  file.writeAsStringSync(content);
  print('Fixed remaining const errors in login_screen.dart');
}
