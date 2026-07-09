// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final enFile = File('assets/translations/en.json');
  final mrFile = File('assets/translations/mr.json');
  final hiFile = File('assets/translations/hi.json');

  String appendKeys(String content, Map<String, String> keys) {
    if (content.endsWith('}\n')) {
      content = content.substring(0, content.length - 2);
    } else if (content.endsWith('}')) {
      content = content.substring(0, content.length - 1);
    }
    
    // Add comma to the last existing key
    final int lastQuote = content.lastIndexOf('"');
    int insertPos = content.indexOf('\n', lastQuote);
    if (insertPos == -1) insertPos = content.length;
    
    // Actually, simple regex to add comma
    content = content.replaceFirst(RegExp(r'"\s*$'), '",\n');

    String newContent = '';
    keys.forEach((key, value) {
      newContent += '  "$key": "$value",\n';
    });
    
    // Remove last comma
    newContent = '${newContent.substring(0, newContent.length - 2)}\n}';
    return content + newContent;
  }

  // EN
  final enKeys = {
    'ui_key_204': 'Welcome Back',
    'ui_key_205': 'Login to continue your green journey.',
    'ui_key_206': 'Email',
    'ui_key_207': 'Enter your email',
    'ui_key_208': 'Password',
    'ui_key_209': 'Enter your password',
    'ui_key_210': 'Forgot Password?',
    'ui_key_211': 'Login',
    'ui_key_212': 'OR',
    'ui_key_213': 'Continue with Google',
    'ui_key_214': "Don't have an account?",
    'ui_key_215': 'Sign up',
    'ui_key_216': 'Please fill in all fields.',
  };
  enFile.writeAsStringSync(appendKeys(enFile.readAsStringSync(), enKeys));

  // MR
  final mrKeys = {
    'ui_key_204': 'पुन्हा स्वागत आहे',
    'ui_key_205': 'तुमचा हरित प्रवास सुरू ठेवण्यासाठी लॉग इन करा.',
    'ui_key_206': 'ईमेल',
    'ui_key_207': 'तुमचा ईमेल प्रविष्ट करा',
    'ui_key_208': 'पासवर्ड',
    'ui_key_209': 'तुमचा पासवर्ड प्रविष्ट करा',
    'ui_key_210': 'पासवर्ड विसरलात?',
    'ui_key_211': 'लॉग इन करा',
    'ui_key_212': 'किंवा',
    'ui_key_213': 'Google सह सुरू ठेवा',
    'ui_key_214': 'तुमचे खाते नाही का?',
    'ui_key_215': 'साइन अप करा',
    'ui_key_216': 'कृपया सर्व फील्ड भरा.',
  };
  mrFile.writeAsStringSync(appendKeys(mrFile.readAsStringSync(), mrKeys));

  // HI
  final hiKeys = {
    'ui_key_204': 'वापसी पर स्वागत है',
    'ui_key_205': 'अपनी हरित यात्रा जारी रखने के लिए लॉग इन करें।',
    'ui_key_206': 'ईमेल',
    'ui_key_207': 'अपना ईमेल दर्ज करें',
    'ui_key_208': 'पासवर्ड',
    'ui_key_209': 'अपना पासवर्ड दर्ज करें',
    'ui_key_210': 'पासवर्ड भूल गए?',
    'ui_key_211': 'लॉग इन करें',
    'ui_key_212': 'या',
    'ui_key_213': 'Google के साथ जारी रखें',
    'ui_key_214': 'क्या आपका खाता नहीं है?',
    'ui_key_215': 'साइन अप करें',
    'ui_key_216': 'कृपया सभी फ़ील्ड भरें।',
  };
  hiFile.writeAsStringSync(appendKeys(hiFile.readAsStringSync(), hiKeys));

  print('JSONs updated');
}
