// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final dir = Directory('lib');
  
  final RegExp unusedIsMarathi1 = RegExp(r'final\s+isMarathi\s*=\s*context\.watch<SettingsProvider>\(\)\.isMarathi;\s*');
  final RegExp unusedIsMarathi2 = RegExp(r'final\s+isMarathi\s*=\s*context\.read<SettingsProvider>\(\)\.isMarathi;\s*');
  final RegExp unusedIsMarathi3 = RegExp(r'bool\s+get\s+isMarathi\s*=>\s*context\.read<SettingsProvider>\(\)\.isMarathi;\s*');
  final RegExp unusedIsMarathi4 = RegExp(r'bool\s+get\s+isMarathi\s*=>\s*context\.watch<SettingsProvider>\(\)\.isMarathi;\s*');
  
  const toggleReplacement = """
if (context.locale.languageCode == 'en') {
  context.setLocale(const Locale('mr'));
} else {
  context.setLocale(const Locale('en'));
}
""";

  final RegExp toggleLang = RegExp(r'context\.read<SettingsProvider>\(\)\.toggleLanguage\(\);');

  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool modified = false;

      if (content.contains('isMarathi')) {
        content = content.replaceAll(unusedIsMarathi1, '');
        content = content.replaceAll(unusedIsMarathi2, '');
        content = content.replaceAll(unusedIsMarathi3, '');
        content = content.replaceAll(unusedIsMarathi4, '');
        modified = true;
      }
      
      if (content.contains('toggleLanguage()')) {
        content = content.replaceAll(toggleLang, toggleReplacement);
        modified = true;
      }
      
      if (modified) {
        // Also ensure easy_localization is imported if we added setLocale
        if (content.contains('context.setLocale') && !content.contains("import 'package:easy_localization/easy_localization.dart';")) {
          final importIndex = content.indexOf('import');
          if (importIndex != -1) {
            final endOfLine = content.indexOf('\n', importIndex);
            content = "${content.substring(0, endOfLine + 1)}import 'package:easy_localization/easy_localization.dart';\n${content.substring(endOfLine + 1)}";
          }
        }
        await entity.writeAsString(content);
        print('Cleaned up ${entity.path}');
      }
    }
  }
}
