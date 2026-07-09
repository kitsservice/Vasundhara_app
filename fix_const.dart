// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/screens/auth/login_screen.dart');
  var content = file.readAsStringSync();
  
  // Quick regex to remove 'const ' from 'const Text(' if it contains .tr()
  // Wait, simpler: just remove all 'const Text(' and replace with 'Text('.
  // It's safe since flutter analyzer will just say we can add const back if needed,
  // but let's just do a blanket replacement.
  content = content.replaceAll('const Text(', 'Text(');

  // We should also look out for const TextStyle(
  content = content.replaceAll('const TextStyle(', 'TextStyle(');

  file.writeAsStringSync(content);
  print('Fixed const in login_screen.dart');
}
