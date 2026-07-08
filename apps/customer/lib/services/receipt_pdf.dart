import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../state/cart_controller.dart';

/// Builds a real, branded PDF receipt for a past order and opens the system
/// share / save / print sheet via the `printing` plugin. This is what powers
/// the "Download Receipt" action on the order-history screen.
Future<void> shareReceiptPdf(OrderHistoryItem order) async {
  const orange = PdfColor.fromInt(0xFF895100);
  const ink = PdfColor.fromInt(0xFF1C1B1A);
  const muted = PdfColor.fromInt(0xFF6B6B6B);

  // Parse "2× Poulet Mayo, 1× Frites" into individual lines for the table.
  final lines = order.itemsDescription
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  final totalFc = (order.total * kUsdToCdf).round();

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TastyLife',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold, color: orange)),
                  pw.Text('Kinshasa · Brazzaville',
                      style: const pw.TextStyle(fontSize: 9, color: muted)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('RECEIPT',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold, color: ink)),
                  pw.Text(order.orderId, style: const pw.TextStyle(fontSize: 10, color: muted)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),

          // Meta
          _metaRow('Restaurant', order.restaurantName),
          _metaRow('Date', order.date),
          _metaRow('Verification PIN', order.verificationPin),
          pw.SizedBox(height: 14),

          pw.Text('Items',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: ink)),
          pw.SizedBox(height: 6),
          ...lines.map((l) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(
                  children: [
                    pw.Text('•  ', style: const pw.TextStyle(color: orange)),
                    pw.Expanded(child: pw.Text(l, style: const pw.TextStyle(fontSize: 11))),
                  ],
                ),
              )),

          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF6EFE6),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total paid',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('\$${order.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold, color: orange)),
                    pw.Text(_fmtFc(totalFc), style: const pw.TextStyle(fontSize: 9, color: muted)),
                  ],
                ),
              ],
            ),
          ),

          pw.Spacer(),
          pw.Center(
            child: pw.Text('Thank you for ordering with TastyLife',
                style: const pw.TextStyle(fontSize: 9, color: muted)),
          ),
        ],
      ),
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'TastyLife-${order.orderId}.pdf',
  );
}

pw.Widget _metaRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label,
                style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF6B6B6B))),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );

String _fmtFc(int fc) {
  final digits = fc.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return '$buf FC';
}
