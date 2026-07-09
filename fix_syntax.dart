// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final filesToFix = [
    'lib/screens/map/nursery_screen.dart',
    'lib/screens/map/nursery_storefront_screen.dart',
    'lib/widgets/home_hero_background.dart',
    'lib/widgets/tree_form_widget.dart',
  ];

  for (var path in filesToFix) {
    final file = File(path);
    if (await file.exists()) {
      var content = await file.readAsString();
      
      if (!content.contains("final isMarathi = context.locale.languageCode == 'mr';")) {
        content = content.replaceFirst(
          'Widget build(BuildContext context) {', 
          "Widget build(BuildContext context) {\n    final isMarathi = context.locale.languageCode == 'mr';",
        );
        
        if (!content.contains("import 'package:easy_localization/easy_localization.dart';")) {
            final importIndex = content.indexOf('import');
            if (importIndex != -1) {
              final endOfLine = content.indexOf('\n', importIndex);
              content = "${content.substring(0, endOfLine + 1)}import 'package:easy_localization/easy_localization.dart';\n${content.substring(endOfLine + 1)}";
            }
        }
        await file.writeAsString(content);
        print('Fixed \$path');
      }
    }
  }
}
