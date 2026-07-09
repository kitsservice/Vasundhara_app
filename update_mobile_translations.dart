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

  // Update ui_key_227
  enMap['ui_key_227'] = 'Contact Person Mobile';
  hiMap['ui_key_227'] = 'संपर्क व्यक्ति का मोबाइल';
  mrMap['ui_key_227'] = 'संपर्क व्यक्तीचा मोबाईल';

  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enMap));
  hiFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(hiMap));
  mrFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mrMap));

  print('Translation keys updated successfully');
}
