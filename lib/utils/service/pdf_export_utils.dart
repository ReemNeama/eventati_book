import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:eventati_book/models/models.dart';


/// PDF-specific colors for document styling
class PdfAppColors {
  static const PdfColor disabled300 = PdfColor.fromInt(0xFFE0E0E0);
  static const PdfColor disabled700 = PdfColor.fromInt(0xFF616161);
}

/// PDF-specific text styles
class PdfTextStyles {
  static const pw.TextStyle bodySmall = pw.TextStyle(fontSize: 10);
  static const pw.TextStyle bodyMedium = pw.TextStyle(fontSize: 12);
  static const pw.TextStyle caption = pw.TextStyle(fontSize: 10, color: PdfAppColors.disabled700);
}

/// Utility class for exporting data to PDF format
class PDFExportUtils {
  /// Generate a PDF document from a saved comparison
  static Future<Uint8List> generateComparisonPDF(
    SavedComparison comparison, {
    bool includeNotes = true,
    bool includeHighlights = true,
  }) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Load fonts
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final italicFont = await PdfGoogleFonts.nunitoItalic();

    // Format date
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(comparison.createdAt);

    // Create a theme
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
    );

    // Add a page to the PDF document
    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (context) =>
                _buildHeader(context, comparison.title, comparison.serviceType),
        footer: (context) => _buildFooter(context, formattedDate),
        build:
            (context) => [
              // Event information (if available)
              if (comparison.eventName != null &&
                  comparison.eventName!.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Row(
                    children: [
                      pw.Text('Event: ', style: pw.TextStyle(font: boldFont)),
                      pw.Text(comparison.eventName!),
                    ],
                  ),
                ),

              // Services being compared
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Services Compared:',
                      style: pw.TextStyle(font: boldFont),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children:
                          comparison.serviceNames
                              .map(
                                (name) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 4),
                                  child: pw.Text('• $name'),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),

              // Notes (if available and included)
              if (includeNotes && comparison.notes.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Notes:', style: pw.TextStyle(font: boldFont)),
                      pw.SizedBox(height: 8),
                      pw.Text(comparison.notes),
                    ],
                  ),
                ),

              // Annotations (if available and included)
              if (includeHighlights &&
                  comparison.annotations != null &&
                  comparison.annotations!.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Highlights:',
                        style: pw.TextStyle(font: boldFont),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children:
                            comparison.annotations!
                                .map(
                                  (annotation) => pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                      bottom: 8,
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          annotation.title,
                                          style: pw.TextStyle(font: boldFont),
                                        ),
                                        pw.SizedBox(height: 4),
                                        pw.Text(annotation.content),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),

              // Comparison date
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Comparison Date: ',
                      style: pw.TextStyle(font: boldFont),
                    ),
                    pw.Text(formattedDate),
                  ],
                ),
              ),

              // Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                child: pw.Text(
                  'This comparison was generated by Eventati Book. '
                  'The information provided is based on the data available at the time of comparison.',
                  style: pw.TextStyle(
                    font: italicFont,
                    fontSize: 10,
                    color: PdfAppColors.disabled700,
                  ),
                ),
              ),
            ],
      ),
    );

    // Return the PDF document as bytes
    return pdf.save();
  }

  /// Build the header for the PDF document
  static pw.Widget _buildHeader(
    pw.Context context,
    String title,
    String serviceType,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfAppColors.disabled300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Service Type: $serviceType',
                style: PdfTextStyles.bodySmall,
              ),
            ],
          ),
          pw.Text(
            'Eventati Book',
            style: PdfTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build the footer for the PDF document
  static pw.Widget _buildFooter(pw.Context context, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfAppColors.disabled300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(date, style: PdfTextStyles.caption),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: PdfTextStyles.caption,
          ),
        ],
      ),
    );
  }

  /// Save a PDF document to a file and return the file path
  static Future<String> savePDF(Uint8List pdfBytes, String fileName) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      // Write the PDF to a file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  /// Share a PDF document
  static Future<void> sharePDF(
    Uint8List pdfBytes,
    String fileName, {
    String subject = 'Eventati Book Comparison',
    String text = 'Here is your comparison from Eventati Book.',
  }) async {
    try {
      // Save the PDF to a file
      final filePath = await savePDF(pdfBytes, fileName);

      // Share the file
      await Share.shareXFiles([XFile(filePath)], subject: subject, text: text);
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Print a PDF document
  static Future<void> printPDF(Uint8List pdfBytes, String documentName) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: documentName,
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }
}
