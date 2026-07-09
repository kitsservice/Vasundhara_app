// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/widgets/professional_drawer.dart');
  var content = file.readAsStringSync();

  // 1. Import
  const importTarget = "import '../screens/gamification/certificates_screen.dart';";
  const importReplacement = "import '../screens/gamification/certificates_screen.dart';\nimport '../screens/core/donate_screen.dart';";
  content = content.replaceFirst(importTarget, importReplacement);

  // 2. Add ListTile
  const listTileTarget = '''          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              CupertinoIcons.doc_text,
              color: AppColors.primary,
            ),''';
            
  const listTileReplacement = '''          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              CupertinoIcons.heart_fill,
              color: Colors.redAccent,
            ),
            title: Text(
              'ui_key_180'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonateScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              CupertinoIcons.doc_text,
              color: AppColors.primary,
            ),''';

  content = content.replaceFirst(listTileTarget, listTileReplacement);

  file.writeAsStringSync(content);
  print('Updated professional_drawer.dart with Donate button');
}
