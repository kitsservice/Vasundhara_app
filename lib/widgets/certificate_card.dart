import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CertificateCard extends StatelessWidget {
  final String userName;
  final String milestone;
  final String backgroundAsset;
  final Color textColor;

  const CertificateCard({
    super.key,
    required this.userName,
    required this.milestone,
    required this.backgroundAsset,
    this.textColor = const Color(0xFF1B5E20), // Default dark green
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.414, // Standard certificate landscape aspect ratio (A4)
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. The Dynamic Background Image
              Image.asset(
                backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if the real asset isn't added yet
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor, width: 4),
                      color: const Color(0xFFF9FAFB),
                    ),
                    child: Center(
                      child: Text(
                        '[Missing Asset: $backgroundAsset]',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                  );
                },
              ),

              // 2. The Dynamic Text Overlay (Perfectly Centered)
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double height = constraints.maxHeight;

                  return Stack(
                    children: [
                      // USER NAME - Perfectly centered
                      Positioned(
                        top: height *
                            0.45, // Adjust this to match your real image's blank space
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: width * 0.1),
                              child: Text(
                                userName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dancingScript(
                                  fontSize: width * 0.09,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // MILESTONE TEXT (e.g. "For planting 10 trees")
                      Positioned(
                        top: height * 0.65, // Below the name
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            milestone,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w600,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),

                      // DATE
                      Positioned(
                        bottom: height * 0.15,
                        left: width * 0.15,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd MMM, yyyy').format(DateTime.now()),
                              style: GoogleFonts.inter(
                                fontSize: width * 0.025,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Container(
                              height: 1,
                              width: width * 0.15,
                              color: textColor,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            Text(
                              'DATE',
                              style: GoogleFonts.inter(
                                fontSize: width * 0.02,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SIGNATURE PLACEHOLDER
                      Positioned(
                        bottom: height * 0.15,
                        right: width * 0.15,
                        child: Column(
                          children: [
                            Text(
                              'G.V.A.',
                              style: GoogleFonts.dancingScript(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Container(
                              height: 1,
                              width: width * 0.15,
                              color: textColor,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            Text(
                              'AUTHORITY',
                              style: GoogleFonts.inter(
                                fontSize: width * 0.02,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
