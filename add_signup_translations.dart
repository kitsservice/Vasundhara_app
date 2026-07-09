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

  // English
  enMap['ui_key_217'] = 'Create Account';
  enMap['ui_key_218'] = 'Join our community of earth guardians.';
  enMap['ui_key_219'] = 'Please fill in all basic fields.';
  enMap['ui_key_220'] = 'Please fill in all community fields.';
  enMap['ui_key_221'] = 'Passwords do not match.';
  enMap['ui_key_222'] = 'Account Type';
  enMap['ui_key_223'] = 'Individual';
  enMap['ui_key_224'] = 'Community based';
  enMap['ui_key_225'] = 'Name of Community';
  enMap['ui_key_226'] = 'Address of the Community';
  enMap['ui_key_227'] = 'Phone No. of Respected Person';
  enMap['ui_key_228'] = 'Contact Person Name';
  enMap['ui_key_229'] = 'Full Name';
  enMap['ui_key_230'] = 'Email Address';
  enMap['ui_key_231'] = 'Password';
  enMap['ui_key_232'] = 'Confirm Password';
  enMap['ui_key_233'] = 'Sign Up';

  // Hindi
  hiMap['ui_key_217'] = 'खाता बनाएं';
  hiMap['ui_key_218'] = 'पृथ्वी रक्षकों के हमारे समुदाय में शामिल हों।';
  hiMap['ui_key_219'] = 'कृपया सभी बुनियादी विवरण भरें।';
  hiMap['ui_key_220'] = 'कृपया समुदाय के सभी विवरण भरें।';
  hiMap['ui_key_221'] = 'पासवर्ड मेल नहीं खाते।';
  hiMap['ui_key_222'] = 'खाता प्रकार';
  hiMap['ui_key_223'] = 'व्यक्तिगत';
  hiMap['ui_key_224'] = 'समुदाय आधारित';
  hiMap['ui_key_225'] = 'समुदाय का नाम';
  hiMap['ui_key_226'] = 'समुदाय का पता';
  hiMap['ui_key_227'] = 'सम्मानित व्यक्ति का फोन नंबर';
  hiMap['ui_key_228'] = 'संपर्क व्यक्ति का नाम';
  hiMap['ui_key_229'] = 'पूरा नाम';
  hiMap['ui_key_230'] = 'ईमेल पता';
  hiMap['ui_key_231'] = 'पासवर्ड';
  hiMap['ui_key_232'] = 'पासवर्ड की पुष्टि करें';
  hiMap['ui_key_233'] = 'साइन अप करें';

  // Marathi
  mrMap['ui_key_217'] = 'खाते तयार करा';
  mrMap['ui_key_218'] = 'आमच्या पृथ्वी रक्षकांच्या समुदायात सामील व्हा.';
  mrMap['ui_key_219'] = 'कृपया सर्व मूलभूत माहिती भरा.';
  mrMap['ui_key_220'] = 'कृपया सर्व समुदाय माहिती भरा.';
  mrMap['ui_key_221'] = 'पासवर्ड जुळत नाहीत.';
  mrMap['ui_key_222'] = 'खात्याचा प्रकार';
  mrMap['ui_key_223'] = 'वैयक्तिक';
  mrMap['ui_key_224'] = 'समुदाय आधारित';
  mrMap['ui_key_225'] = 'समुदायाचे नाव';
  mrMap['ui_key_226'] = 'समुदायाचा पत्ता';
  mrMap['ui_key_227'] = 'आदरणीय व्यक्तीचा फोन नंबर';
  mrMap['ui_key_228'] = 'संपर्क व्यक्तीचे नाव';
  mrMap['ui_key_229'] = 'पूर्ण नाव';
  mrMap['ui_key_230'] = 'ईमेल पत्ता';
  mrMap['ui_key_231'] = 'पासवर्ड';
  mrMap['ui_key_232'] = 'पासवर्डची पुष्टी करा';
  mrMap['ui_key_233'] = 'साइन अप करा';

  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enMap));
  hiFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(hiMap));
  mrFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(mrMap));

  print('Translation keys added successfully');
}
