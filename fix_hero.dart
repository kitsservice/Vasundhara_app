// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('lib/widgets/home_hero_background.dart');
  String content = file.readAsStringSync();

  // Find the exact text span block to replace
  const target = '''                      children: isMarathi
                          ? [
                              const TextSpan(
                                text:
                                    'या चळवळीत सामील व्हा. अधिक झाडे लावा आणि आपल्या ग्रहाला ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF047857),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'हिरवेगार बनवा.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          : [
                              const TextSpan(
                                text:
                                    'Join the movement. Plant more trees and make our ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF047857),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'planet greener.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],''';

  const replacement = '''                      children: () {
                        final code = context.locale.languageCode;
                        String prefixText = 'Join the movement. Plant more trees and make our ';
                        String highlightText = 'planet greener.';
                        
                        if (code == 'mr') {
                          prefixText = 'या चळवळीत सामील व्हा. अधिक झाडे लावा आणि आपल्या ग्रहाला ';
                          highlightText = 'हिरवेगार बनवा.';
                        } else if (code == 'hi') {
                          prefixText = 'इस अभियान में शामिल हों। अधिक पेड़ लगाएं और हमारे ग्रह को ';
                          highlightText = 'हरा-भरा बनाएं।';
                        }
                        
                        return [
                          TextSpan(text: prefixText),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF047857),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                highlightText,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ];
                      }(),''';

  if (content.contains(target)) {
    content = content.replaceFirst(target, replacement);
    file.writeAsStringSync(content);
    print('SUCCESS');
  } else {
    print('FAILED: Target not found');
  }
}
