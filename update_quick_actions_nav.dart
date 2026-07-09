// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final gridFile = File('lib/widgets/quick_actions_grid.dart');
  var content = gridFile.readAsStringSync();

  // Add import
  const importTarget = "import '../screens/core/donate_screen.dart';";
  const importReplacement = "import '../screens/core/donate_screen.dart';\nimport '../screens/gamification/communities_list_screen.dart';";
  content = content.replaceFirst(importTarget, importReplacement);

  // Update navigation
  const target = '''onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Communities feature coming soon!')),
                  );
                },''';
  const replacement = '''onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CommunitiesListScreen(),
                    ),
                  );
                },''';

  content = content.replaceFirst(target, replacement);
  gridFile.writeAsStringSync(content);
  print('Updated quick_actions_grid.dart navigation');
}
