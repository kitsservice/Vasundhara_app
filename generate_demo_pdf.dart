// ignore_for_file: avoid_print
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

void main() async {
  final pdf = pw.Document();

  // Fetch fonts
  final titleFont = await PdfGoogleFonts.outfitExtraBold();
  final nameFont = await PdfGoogleFonts.dancingScriptBold();
  final bodyFont = await PdfGoogleFonts.interRegular();
  final boldFont = await PdfGoogleFonts.interBold();

  final date = DateFormat('MMMM d, yyyy').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFF059669),
              width: 10,
            ),
          ),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFF34D399),
                width: 2,
              ),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICATE',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 48,
                    color: const PdfColor.fromInt(0xFF065F46),
                    letterSpacing: 4,
                  ),
                ),
                pw.Text(
                  'OF ENVIRONMENTAL EXCELLENCE',
                  style: pw.TextStyle(
                    font: titleFont,
                    fontSize: 18,
                    color: const PdfColor.fromInt(0xFF10B981),
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'THIS IS PROUDLY PRESENTED TO',
                  style: pw.TextStyle(
                    font: bodyFont,
                    fontSize: 14,
                    color: PdfColors.grey700,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'YASH SHARMA', // Demo name
                  style: pw.TextStyle(
                    font: nameFont,
                    fontSize: 64,
                    color: const PdfColor.fromInt(0xFF047857),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 300,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'For achieving the esteemed rank of',
                  style: pw.TextStyle(
                    font: bodyFont,
                    fontSize: 16,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Forest Master', // Demo rank
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                    color: const PdfColor.fromInt(0xFFF59E0B),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'by successfully planting 150 trees.', // Demo count
                  style: pw.TextStyle(
                    font: bodyFont,
                    fontSize: 16,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Your dedication to a greener planet inspires us all.',
                  style: pw.TextStyle(
                    font: bodyFont,
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 50),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          date,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 14,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Date Awarded',
                          style: pw.TextStyle(
                            font: bodyFont,
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: const PdfColor.fromInt(0xFFECFDF5),
                        border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFF10B981),
                          width: 3,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'VERIFIED',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 12,
                            color: const PdfColor.fromInt(0xFF047857),
                          ),
                        ),
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Vasundhara Foundation',
                          style: pw.TextStyle(
                            font: nameFont,
                            fontSize: 24,
                            color: const PdfColor.fromInt(0xFF047857),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 150,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Official Signature',
                          style: pw.TextStyle(
                            font: bodyFont,
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  final file = File('d:\\Vasundhara_app\\DEMO_CERTIFICATE.pdf');
  await file.writeAsBytes(await pdf.save());
  print('Saved to ${file.path}');
}
