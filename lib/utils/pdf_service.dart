import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';

class PdfService {
  static Future<void> shareInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    final imageBytes = await rootBundle.load('assets/app-logo.png');
    final appLogo = pw.MemoryImage(imageBytes.buffer.asUint8List());

    String customerName = invoice.customerData['fullName'] ?? invoice.customerData['name'] ?? 'Unknown Customer';
    String address = invoice.customerData['address'] ?? '';
    String phone = invoice.customerData['phoneNumber'] ?? invoice.customerData['phone'] ?? '';
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Image(appLogo, height: 50),
                ]
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:'),
                      pw.Text(customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(address),
                      pw.Text(phone),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${invoice.invoiceNumber ?? "N/A"}'),
                      pw.Text('Date: ${invoice.invoiceDate}'),
                      pw.Text('Type: ${invoice.type}'),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                headers: ['Product', 'Qty', 'Price', 'Total'],
                data: invoice.items.map((item) {
                  return [
                    item.product.name,
                    item.quantity.toString(),
                    item.product.price.toStringAsFixed(2),
                    item.total.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: Rs ${invoice.subtotal.toStringAsFixed(2)}'),
                    if (invoice.isGstApplied) ...[
                      pw.Text('CGST (9%): Rs ${invoice.cgst.toStringAsFixed(2)}'),
                      pw.Text('SGST (9%): Rs ${invoice.sgst.toStringAsFixed(2)}'),
                    ],
                    pw.Divider(),
                    pw.Text('Grand Total: Rs ${invoice.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]
                )
              )
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${invoice.invoiceNumber ?? "new"}.pdf');
  }
}
