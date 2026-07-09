// ignore_for_file: avoid_print
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

void main() async {
  final pdf = pw.Document();

  // Fetch fonts
  final serifFont = await PdfGoogleFonts.playfairDisplayRegular();
  final serifBold = await PdfGoogleFonts.playfairDisplayBold();
  final nameFont = await PdfGoogleFonts.greatVibesRegular(); // Elegant cursive
  final bodyFont = await PdfGoogleFonts.montserratRegular();

  final date = DateFormat('dd MMMM yyyy').format(DateTime.now());

  // Colors based on the image
  const creamBg = PdfColor.fromInt(0xFFF9F6EE);
  const darkGreen = PdfColor.fromInt(0xFF1B4332);
  const goldColor = PdfColor.fromInt(0xFFC5A059);
  const textDark = PdfColor.fromInt(0xFF333333);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Container(
          color: creamBg,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: darkGreen, width: 8),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: goldColor, width: 1.5),
              ),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Header
                  pw.Column(
                    children: [
                      pw.Icon(
                        const pw.IconData(0xe52f),
                        color: darkGreen,
                        size: 40,
                      ), // Tree icon fallback
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'VASUNDHARA',
                        style: pw.TextStyle(
                          font: serifBold,
                          fontSize: 28,
                          color: darkGreen,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.Text(
                        '— TREE PLANTATION —',
                        style: pw.TextStyle(
                          font: bodyFont,
                          fontSize: 10,
                          color: darkGreen,
                          letterSpacing: 3,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'PLANT TODAY • NURTURE TOMORROW • PRESERVE FOREVER',
                        style: pw.TextStyle(
                          font: bodyFont,
                          fontSize: 6,
                          color: goldColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Title
                  pw.Text(
                    'SUSTAINABILITY LEADERSHIP CERTIFICATE',
                    style: pw.TextStyle(
                      font: serifBold,
                      fontSize: 26,
                      color: darkGreen,
                      letterSpacing: 1.5,
                    ),
                  ),

                  // Presented To
                  pw.Column(
                    children: [
                      pw.Text(
                        'THIS CERTIFICATE IS PROUDLY PRESENTED TO',
                        style: pw.TextStyle(
                          font: bodyFont,
                          fontSize: 10,
                          color: textDark,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'Sarthak Kumarrao Joshi',
                        style: pw.TextStyle(
                          font: nameFont,
                          fontSize: 60,
                          color: goldColor,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(width: 400, height: 1, color: goldColor),
                    ],
                  ),

                  // Description
                  pw.Column(
                    children: [
                      pw.Text(
                        'in recognition of your dedicated contribution to environmental sustainability,',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 12,
                          color: textDark,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'tree care, and green community development through the plantation of',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 12,
                          color: textDark,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '1 TREE.',
                        style: pw.TextStyle(
                          font: serifBold,
                          fontSize: 14,
                          color: darkGreen,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'Your commitment and leadership inspire positive change and',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 10,
                          color: textDark,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'help build a greener, healthier, and sustainable tomorrow for all.',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 10,
                          color: textDark,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Thank you for being a true guardian of our planet.',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 10,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),

                  // Footer
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Date
                      pw.Column(
                        children: [
                          pw.Text(
                            date,
                            style: pw.TextStyle(
                              font: serifBold,
                              fontSize: 12,
                              color: textDark,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(width: 120, height: 1, color: goldColor),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'DATE',
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: 10,
                              color: textDark,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Seal
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: goldColor,
                          border: pw.Border.all(color: creamBg, width: 2),
                          boxShadow: const [
                            pw.BoxShadow(
                              color: PdfColors.grey600,
                              blurRadius: 4,
                              offset: PdfPoint(0, 2),
                            ),
                          ],
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'PLANT',
                                style: pw.TextStyle(
                                  font: bodyFont,
                                  fontSize: 6,
                                  color: creamBg,
                                ),
                              ),
                              pw.Icon(
                                const pw.IconData(0xe52f),
                                color: creamBg,
                                size: 20,
                              ),
                              pw.Text(
                                'NURTURE',
                                style: pw.TextStyle(
                                  font: bodyFont,
                                  fontSize: 6,
                                  color: creamBg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Certificate ID
                      pw.Column(
                        children: [
                          pw.Text(
                            'VTP-2026-103',
                            style: pw.TextStyle(
                              font: serifBold,
                              fontSize: 12,
                              color: textDark,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(width: 120, height: 1, color: goldColor),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'CERTIFICATE ID',
                            style: pw.TextStyle(
                              font: bodyFont,
                              fontSize: 10,
                              color: textDark,
                              letterSpacing: 1.5,
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
        );
      },
    ),
  );

  final file = File('d:\\Vasundhara_app\\Sarthak_Joshi_Certificate.pdf');
  await file.writeAsBytes(await pdf.save());
  print('Saved custom demo to ${file.path}');
}
