// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return;

  int filesModified = 0;
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = file.readAsStringSync();
      bool modified = false;

      // Replace Provider.of<T>(context, listen: false) with context.read<T>()
      final readRegex = RegExp(r'Provider\.of<([a-zA-Z0-9_]+)>\(\s*context\s*,\s*listen\s*:\s*false\s*\)');
      if (readRegex.hasMatch(content)) {
        content = content.replaceAllMapped(readRegex, (match) => 'context.read<${match.group(1)}>()');
        modified = true;
      }

      // Replace Provider.of<T>(context) with context.watch<T>()
      final watchRegex = RegExp(r'Provider\.of<([a-zA-Z0-9_]+)>\(\s*context\s*\)');
      if (watchRegex.hasMatch(content)) {
        content = content.replaceAllMapped(watchRegex, (match) => 'context.watch<${match.group(1)}>()');
        modified = true;
      }

      if (modified) {
        file.writeAsStringSync(content);
        filesModified++;
        print('Refactored Provider in ${file.path}');
      }
    }
  }
  print('Refactored Provider in $filesModified files.');
}
