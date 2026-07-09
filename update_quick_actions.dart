// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() {
  final enFile = File('assets/translations/en.json');
  final hiFile = File('assets/translations/hi.json');
  final mrFile = File('assets/translations/mr.json');

  final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final hiMap = jsonDecode(hiFile.readAsStringSync()) as Map<String, dynamic>;
  final mrMap = jsonDecode(mrFile.readAsStringSync()) as Map<String, dynamic>;

  // Add ui_key_234
  enMap['ui_key_234'] = 'Communities';
  hiMap['ui_key_234'] = 'समुदाय';
  mrMap['ui_key_234'] = 'समुदाय';

  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enMap));
  hiFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(hiMap));
  mrFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mrMap));

  print('Translation keys updated successfully');

  // Now update quick_actions_grid.dart
  final gridFile = File('lib/widgets/quick_actions_grid.dart');
  var content = gridFile.readAsStringSync();

  const target = 'const Expanded(child: SizedBox()),';
  const replacement = '''Expanded(
              child: SquareActionCard(
                icon: CupertinoIcons.person_3_fill,
                title: 'ui_key_234'.tr(),
                iconColor: const Color(0xFF6B21A8),
                iconBackgroundColor: const Color(0xFFE9D5FF),
                backgroundGradient: const [
                  Color(0xFFFAF5FF),
                  Color(0xFFF3E8FF),
                ],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Communities feature coming soon!')),
                  );
                },
              ),
            ),''';

  content = content.replaceFirst(target, replacement);
  gridFile.writeAsStringSync(content);
  print('quick_actions_grid.dart updated successfully');
}
