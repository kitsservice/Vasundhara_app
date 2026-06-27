import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class CertificateScreen extends StatefulWidget {
  final String userName;
  final String title;
  final String milestone;
  final int trees;

  const CertificateScreen({
    super.key,
    required this.userName,
    required this.title,
    required this.milestone,
    required this.trees,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareCertificate() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 1. Capture the widget as an image
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      // High pixel ratio for sharp image quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save image to temp directory
      final directory = await getTemporaryDirectory();
      final imagePath =
          await File('${directory.path}/vasundhara_certificate.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // 3. Share the image
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)],
          text:
              'I just earned the ${widget.title} Certificate on Vasundhara Tree Plantation for planting ${widget.trees} trees! 🌳 Join the Green Vasundhara Abhiyan today!',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating certificate: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine orientation based on screen width/height to ensure it looks like a landscape cert
    // Even in portrait mode on a phone, we will force the UI to be a beautiful square/landscape card.

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // Dark green background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Your Certificate',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The actual certificate wrapped in RepaintBoundary
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF2E7D32), width: 4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Color(0xFF2E7D32),
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Vasundhara Tree Plantation',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'CERTIFICATE OF APPRECIATION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB8860B), // Golden text
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'THIS IS PROUDLY PRESENTED TO',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.userName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dancingScript(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 8,
                          ),
                          height: 1,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'For outstanding contribution to the environment by achieving the milestone of',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.milestone.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  DateFormat('dd MMM, yyyy')
                                      .format(DateTime.now()),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  width: 80,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                ),
                                Text(
                                  'DATE',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              CupertinoIcons.rosette,
                              color: Color(0xFFB8860B),
                              size: 50,
                            ),
                            Column(
                              children: [
                                Text(
                                  'G.V.A.', // Green Vasundhara Abhiyan Signature placeholder
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B5E20),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  width: 80,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                ),
                                Text(
                                  'AUTHORITY',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Share Button (Not part of the screenshot)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _shareCertificate,
                    icon: _isSharing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(CupertinoIcons.share, color: Colors.white),
                    label: Text(
                      _isSharing ? 'Generating...' : 'Share Certificate',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B), // Golden orange
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
