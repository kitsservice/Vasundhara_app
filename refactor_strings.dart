// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() async {
  final dir = Directory('lib');
  final enMap = <String, String>{};
  final mrMap = <String, String>{};
  int keyCounter = 1;

  // We are looking for exactly: isMarathi ? 'mrString' : 'enString'
  // Or isMarathi ? "mrString" : "enString"
  final RegExp regex1 = RegExp(r"isMarathi\s*\?\s*'([^']+)'\s*:\s*'([^']+)'");
  final RegExp regex2 = RegExp(r'isMarathi\s*\?\s*"([^"]+)"\s*:\s*"([^"]+)"');

  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool modified = false;

      // Ensure easy_localization is imported if we are about to modify
      content = content.replaceAllMapped(regex1, (match) {
        final mrString = match.group(1)!;
        final enString = match.group(2)!;
        final key = 'ui_key_$keyCounter';
        keyCounter++;
        enMap[key] = enString;
        mrMap[key] = mrString;
        modified = true;
        return "'$key'.tr()";
      });

      content = content.replaceAllMapped(regex2, (match) {
        final mrString = match.group(1)!;
        final enString = match.group(2)!;
        final key = 'ui_key_$keyCounter';
        keyCounter++;
        enMap[key] = enString;
        mrMap[key] = mrString;
        modified = true;
        return "'$key'.tr()";
      });

      if (modified) {
        if (!content.contains("import 'package:easy_localization/easy_localization.dart';")) {
          // Insert after the first import
          final importIndex = content.indexOf('import');
          if (importIndex != -1) {
            final endOfLine = content.indexOf('\n', importIndex);
            content = "${content.substring(0, endOfLine + 1)}import 'package:easy_localization/easy_localization.dart';\n${content.substring(endOfLine + 1)}";
          }
        }
        await entity.writeAsString(content);
        print('Refactored ${entity.path}');
      }
    }
  }

  await File('assets/translations/en.json').writeAsString(const JsonEncoder.withIndent('  ').convert(enMap));
  await File('assets/translations/mr.json').writeAsString(const JsonEncoder.withIndent('  ').convert(mrMap));
  
  // Create an empty hi.json with the same keys
  final hiMap = <String, String>{};
  for (var key in enMap.keys) {
    hiMap[key] = ''; // To be translated later
  }
  await File('assets/translations/hi.json').writeAsString(const JsonEncoder.withIndent('  ').convert(hiMap));

  print('Extraction complete. Found ${keyCounter - 1} strings.');
}
