import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/restaurant.dart';
import '../models/transaction.dart';
import '../models/product.dart';

class PdfService {
  Future<pw.Font> _loadArabicFont() async {
    // Load Arabic font from Google Fonts
    final fontData = await PdfGoogleFonts.cairoRegular();
    return fontData;
  }

  Future<File> generateRestaurantReport({
    required Restaurant restaurant,
    required List<Transaction> transactions,
    required Map<String, Product> productMap,
  }) async {
    final pdf = pw.Document();
    final arabicFont = await _loadArabicFont();

    // Calculate totals
    double totalDelivered = 0;
    double totalReturned = 0;
    double totalUsed = 0;

    for (var transaction in transactions) {
      totalDelivered += transaction.jarsDelivered.toDouble();
      totalReturned += transaction.jarsReturned.toDouble();
      totalUsed += transaction.jarsUsed.toDouble();
    }

    // Add page with RTL support and Arabic font
    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير المطعم',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        font: arabicFont,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      restaurant.name,
                      style: pw.TextStyle(fontSize: 18, font: arabicFont),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'الرصيد الإجمالي: ${restaurant.balance?.toStringAsFixed(3) ?? '0.000'} د.أ',
                      style: pw.TextStyle(fontSize: 14, font: arabicFont),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ملخص الحركات',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: arabicFont,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('إجمالي المسلم:', style: pw.TextStyle(font: arabicFont)),
                        pw.Text('${totalDelivered.toStringAsFixed(0)} برطمان', style: pw.TextStyle(font: arabicFont)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('إجمالي المرتجع:', style: pw.TextStyle(font: arabicFont)),
                        pw.Text('${totalReturned.toStringAsFixed(0)} برطمان', style: pw.TextStyle(font: arabicFont)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'إجمالي العلب الفارغة:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                        pw.Text(
                          '${totalUsed.toStringAsFixed(0)} برطمان',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFont),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Transactions table
              pw.Text(
                'تفاصيل الحركات',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont,
                ),
              ),
              pw.SizedBox(height: 10),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('الرقم', arabicFont, isHeader: true),
                      _buildTableCell('التاريخ', arabicFont, isHeader: true),
                      _buildTableCell('المسلم', arabicFont, isHeader: true),
                      _buildTableCell('المرتجع', arabicFont, isHeader: true),
                      _buildTableCell('الفارغة', arabicFont, isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...transactions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final transaction = entry.value;
                    final delivered = transaction.jarsDelivered.toDouble();
                    final returned = transaction.jarsReturned.toDouble();
                    final used = transaction.jarsUsed.toDouble();
                    final dateStr = '${transaction.deliveryDate.year}-${transaction.deliveryDate.month.toString().padLeft(2, '0')}-${transaction.deliveryDate.day.toString().padLeft(2, '0')}';

                    return pw.TableRow(
                      children: [
                        _buildTableCell(index.toString(), arabicFont),
                        _buildTableCell(dateStr, arabicFont),
                        _buildTableCell(delivered.toStringAsFixed(0), arabicFont),
                        _buildTableCell(returned.toStringAsFixed(0), arabicFont),
                        _buildTableCell(used.toStringAsFixed(0), arabicFont),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
            ],
          );
        },
      ),
    );

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/restaurant_report_${restaurant.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  Future<void> printReport(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Future<void> shareReport(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}
