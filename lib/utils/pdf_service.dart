import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';

class PdfService {
  static String numberToWords(int number) {
    if (number == 0) return 'Zero';

    final List<String> units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertUnderOneThousand(int n) {
      String word = '';
      if (n % 100 < 20) {
        word = units[n % 100];
        n = n ~/ 100;
      } else {
        word = units[n % 10];
        n = n ~/ 10;
        word = tens[n % 10] + (word.isNotEmpty ? ' $word' : '');
        n = n ~/ 10;
      }
      if (n == 0) return word;
      return '${units[n]} Hundred${word.isNotEmpty ? ' and $word' : ''}';
    }

    String result = '';
    if (number >= 10000000) {
      result += '${convertUnderOneThousand(number ~/ 10000000)} Crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      result += '${convertUnderOneThousand(number ~/ 100000)} Lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      result += '${convertUnderOneThousand(number ~/ 1000)} Thousand ';
      number %= 1000;
    }
    if (number > 0) {
      result += convertUnderOneThousand(number);
    }
    return result.trim();
  }

  static Future<Uint8List> generateInvoicePdfBytes(InvoiceModel invoice) async {
    final pdf = pw.Document();

    final imageBytes = await rootBundle.load('assets/app-logo.png');
    final appLogo = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final smartroBytes = await rootBundle.load('assets/smartro.png');
    final smartroLogo = pw.MemoryImage(smartroBytes.buffer.asUint8List());

    final sigBytes = await rootBundle.load('assets/signature.png');
    final signatureImage = pw.MemoryImage(sigBytes.buffer.asUint8List());

    final lgBytes = await rootBundle.load('assets/lg.png');
    final lgLogo = pw.MemoryImage(lgBytes.buffer.asUint8List());

    final aquaBytes = await rootBundle.load('assets/aqua.png');
    final aquaLogo = pw.MemoryImage(aquaBytes.buffer.asUint8List());

    final hawellsBytes = await rootBundle.load('assets/hawells.png');
    final hawellsLogo = pw.MemoryImage(hawellsBytes.buffer.asUint8List());

    final vgaurdBytes = await rootBundle.load('assets/v-gaurd.png');
    final vgaurdLogo = pw.MemoryImage(vgaurdBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => _buildHeader(invoice, appLogo),
        footer: (context) =>
            _buildFooter(lgLogo, aquaLogo, hawellsLogo, vgaurdLogo),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 20),
                _buildCustomerInfo(invoice),
                pw.SizedBox(height: 20),
              ],
            ),
          ),
          _buildTable(invoice),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildLeftNotes(invoice),
                    _buildRightTotals(invoice),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: _buildSignature(signatureImage, smartroLogo),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  static Future<void> shareInvoicePdf(InvoiceModel invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${invoice.invoiceNumber ?? "new"}.pdf',
    );
  }

  static pw.Widget _buildHeader(
    InvoiceModel invoice,
    pw.ImageProvider appLogo,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(
        left: 40,
        right: 40,
        top: 20,
        bottom: 0,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(appLogo, width: 140),
              pw.SizedBox(height: 15),
              pw.Text(
                invoice.isGstApplied
                    ? 'Address: No.1/756, Adheeshwarar Nagar 3rd Street, \nAdhiyur, Kunnathur, Tiruppur - 638103'
                    : '9/1,sri nagar,deepam nagar 9th Street, irugur,641103',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Ph: 6383450508, 9790188321',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                invoice.isGstApplied ? 'TAX INVOICE' : 'PROFORMA INVOICE',
                style: pw.TextStyle(
                  fontSize: invoice.isGstApplied ? 20 : 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#5A9BD5'),
                ),
              ),
              pw.SizedBox(height: 8),
              if (invoice.isGstApplied)
                pw.Text(
                  'GSTIN: 33JXVPS7863A1ZQ',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(InvoiceModel invoice) {
    String customerName =
        (invoice.customerData['fullName'] ?? invoice.customerData['name'])
            ?.toString() ??
        'Unknown Customer';

    String address = invoice.customerData['address']?.toString() ?? '';
    String city = invoice.customerData['city']?.toString() ?? '';
    String state = invoice.customerData['state']?.toString() ?? '';
    String pincode = invoice.customerData['pincode']?.toString() ?? '';

    String fullAddr = address;
    if (city.isNotEmpty && city != 'null') {
      fullAddr += (fullAddr.isNotEmpty ? ', $city' : city);
    }
    if (state.isNotEmpty && state != 'null') {
      fullAddr += (fullAddr.isNotEmpty ? ', $state' : state);
    }
    if (pincode.isNotEmpty && pincode != 'null') {
      fullAddr += (fullAddr.isNotEmpty ? ' - $pincode' : pincode);
    }

    String phone =
        (invoice.customerData['phoneNumber'] ?? invoice.customerData['phone'])
            ?.toString() ??
        '';
    String email = invoice.customerData['email']?.toString() ?? '';
    String gst = invoice.customerData['gstnumber']?.toString() ?? '';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Billing to:',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                customerName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 200, height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              if (phone.trim().isNotEmpty && phone != 'null')
                _buildInfoRow('Phone', phone),
              if (email.trim().isNotEmpty && email != 'null')
                _buildInfoRow('Email', email),
              if (fullAddr.trim().isNotEmpty && fullAddr != 'null')
                _buildInfoRow('Address', fullAddr),
              if (gst.trim().isNotEmpty && gst != 'null')
                _buildIGstInfoRow('GST Number : ', gst),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(
                    'Invoice No',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  ': ${invoice.invoiceNumber ?? ""}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  ': ${invoice.invoiceDate}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildIGstInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(InvoiceModel invoice) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(3),
          2: const pw.FlexColumnWidth(1.5),
          3: const pw.FlexColumnWidth(2),
          4: const pw.FlexColumnWidth(1.5),
          5: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#5A9BD5')),
            children: [
              _buildTableHeader('P-ID', align: pw.TextAlign.center),
              _buildTableHeader('ITEM DESCRIPTION', align: pw.TextAlign.left),
              _buildTableHeader('HSN CODE', align: pw.TextAlign.left),
              _buildTableHeader('UNIT PRICE', align: pw.TextAlign.center),
              _buildTableHeader('QUANTITY', align: pw.TextAlign.center),
              _buildTableHeader('TOTAL PRICE', align: pw.TextAlign.center),
            ],
          ),
          ...invoice.items.asMap().entries.map((entry) {
            int idx = entry.key + 1;
            var item = entry.value;
            return pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell(
                  idx.toString().padLeft(2, '0'),
                  align: pw.TextAlign.center,
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: pw.RichText(
                    textAlign: pw.TextAlign.left,
                    text: pw.TextSpan(
                      text: item.product.name,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                      children: [
                        if (item.product.description != null &&
                            item.product.description!.isNotEmpty)
                          pw.TextSpan(
                            text: '\n${item.product.description}',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _buildTableCell(
                  item.product.hsncode ?? '-',
                  align: pw.TextAlign.center,
                ),
                _buildTableCell(
                  'Rs.${item.product.price.toStringAsFixed(2)}',
                  align: pw.TextAlign.center,
                ),
                _buildTableCell(
                  item.quantity.toString(),
                  align: pw.TextAlign.center,
                ),
                _buildTableCell(
                  'Rs.${item.total.toStringAsFixed(2)}',
                  align: pw.TextAlign.center,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildLeftNotes(InvoiceModel invoice) {
    return pw.Expanded(
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(right: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Total In Words Indian Rupee',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#5A9BD5'),
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${numberToWords(invoice.grandTotal.round())} Only',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'Notes',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#5A9BD5'),
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Thanks for your business.',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 15),
            if (invoice.termsnotes != null &&
                invoice.termsnotes!.isNotEmpty) ...[
              pw.Text(
                'Terms & Conditions',
                style: pw.TextStyle(
                  color: PdfColor.fromHex('#5A9BD5'),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                invoice.termsnotes ?? '',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
            pw.SizedBox(height: 20),
            if (invoice.isGstApplied) ...[
              pw.Row(
                children: [
                  pw.Text(
                    'PAYMENT METHOD : ',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#5A9BD5'),
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    (invoice.paymentmethod ?? 'Cash').toUpperCase(),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text(
                    'PAYMENT STATUS : ',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#5A9BD5'),
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    (invoice.paymentstatus ?? 'Unpaid').toUpperCase(),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildRightTotals(InvoiceModel invoice) {
    double totalGst = invoice.cgst + invoice.sgst + invoice.igst;
    return pw.Container(
      width: 250,
      child: pw.Column(
        children: [
          _buildTotalRow(
            'SUB TOTAL -',
            'Rs.${invoice.subtotal.toStringAsFixed(2)}',
          ),
          if (invoice.isGstApplied) ...[
            _buildTotalRow('CGST (9%) -', 'Rs.${invoice.cgst.toStringAsFixed(2)}'),
            _buildTotalRow('SGST (9%) -', 'Rs.${invoice.sgst.toStringAsFixed(2)}'),
          ],
          _buildTotalRow(
            'DISCOUNT -',
            'Rs.${invoice.totalDiscount.toStringAsFixed(2)}',
            valueColor: PdfColor.fromHex('#2ECC71'),
            textColor: PdfColor.fromHex('#2ECC71'),
          ),
          pw.Container(
            color: PdfColor.fromHex('#2D3748'),
            padding: const pw.EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 15,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GRAND TOTAL -',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  'Rs.${invoice.grandTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    PdfColor? textColor,
    PdfColor? valueColor,
  }) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: textColor ?? PdfColors.black,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor ?? PdfColors.black,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignature(
    pw.ImageProvider signatureImage,
    pw.ImageProvider smartroLogo,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 180,
                height: 50,
                child: pw.Stack(
                  children: [
                    pw.Positioned(
                      left: 0,
                      top: 0,
                      child: pw.Image(
                        signatureImage,
                        height: 50,
                        fit: pw.BoxFit.contain,
                      ),
                    ),

                    // Increased gap between signature and logo
                    pw.Positioned(
                      left: 100,
                      top: 0,
                      child: pw.Image(
                        smartroLogo,
                        height: 50,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Container(width: 250, height: 1.5, color: PdfColors.black),

              pw.SizedBox(height: 5),

              pw.Text(
                'Thank you for choosing our business',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    pw.ImageProvider lgLogo,
    pw.ImageProvider aquaLogo,
    pw.ImageProvider hawellsLogo,
    pw.ImageProvider vgaurdLogo,
  ) {
    return pw.Container(
      width: double.infinity,
      color: PdfColor.fromHex('#5A9BD5'),
      padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Thank you for contacting us! Our services:',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Multi services & sales available : Building construction,water level controller,Ac,water purifier,fridge, washing machine, dish washer,cctv, UPS, solar power system, stabilizer, chimney,water heater,solar heater, plumbing, electrical, house cleaning ,home shifting, fabrication, automation, Lightings, Smart switches, Painting works,generators,Ro plants, softener etc...',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(lgLogo, height: 25),
                    pw.SizedBox(width: 15),
                    pw.Image(
                      aquaLogo,
                      height: 40,
                      width: 60,
                      fit: pw.BoxFit.cover,
                    ),
                    pw.SizedBox(width: 15),
                    pw.Image(hawellsLogo, height: 25),
                    pw.SizedBox(width: 15),
                    pw.Image(vgaurdLogo, height: 25),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(3),
            color: PdfColors.white,
            child: pw.BarcodeWidget(
              data: 'https://www.smartro.shop/',
              width: 55,
              height: 55,
              barcode: pw.Barcode.qrCode(),
              drawText: false,
            ),
          ),
        ],
      ),
    );
  }
}
