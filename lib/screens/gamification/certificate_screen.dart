import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../widgets/certificate_card.dart';

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

      // 2. Create the PDF Document
      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imageProvider),
            );
          },
        ),
      );

      // 3. Save PDF to temp directory
      final directory = await getTemporaryDirectory();
      final pdfPath =
          await File('${directory.path}/Vasundhara_Certificate.pdf').create();
      await pdfPath.writeAsBytes(await pdf.save());

      // 4. Share the PDF
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfPath.path)],
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

    // Determine Certificate Tier
    String backgroundAsset = 'assets/images/certs/basic.png';
    Color textColor = const Color(0xFF1B5E20); // Dark Green

    if (widget.trees >= 100) {
      backgroundAsset = 'assets/images/certs/premium.png';
      textColor = const Color(0xFFFFD700); // Gold
    } else if (widget.trees >= 50) {
      backgroundAsset = 'assets/images/certs/platinum.png';
      textColor = const Color(0xFF1F2937); // Very Dark Grey
    } else if (widget.trees >= 25) {
      backgroundAsset = 'assets/images/certs/gold.png';
      textColor = const Color(0xFFB8860B); // Dark Golden
    } else if (widget.trees >= 10) {
      backgroundAsset = 'assets/images/certs/silver.png';
      textColor = const Color(0xFF374151); // Dark Silver/Grey
    }

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CertificateCard(
                    userName: widget.userName,
                    milestone:
                        'In recognition of planting ${widget.trees} trees.',
                    backgroundAsset: backgroundAsset,
                    textColor: textColor,
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
                      _isSharing ? 'Generating PDF...' : 'Download / Share PDF',
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
