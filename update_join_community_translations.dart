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

  // Add ui_key_235
  enMap['ui_key_235'] = 'Join Communities';
  hiMap['ui_key_235'] = 'समुदाय में शामिल हों';
  mrMap['ui_key_235'] = 'समुदायात सामील व्हा';

  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enMap));
  hiFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(hiMap));
  mrFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mrMap));

  print('Translation keys for Join Communities updated successfully');
}
