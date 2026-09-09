import 'product_model.dart';
import 'dart:convert';

class InvoiceItemModel {
  ProductModel product;
  int quantity;

  InvoiceItemModel({required this.product, required this.quantity});

  double get total => product.price * quantity;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('product') && json['product'] != null) {
      return InvoiceItemModel(
        product: ProductModel.fromJson(json['product']),
        quantity: json['quantity'] ?? 1,
      );
    } else {
      return InvoiceItemModel(
        product: ProductModel(
          id: json['id'] ?? '',
          productname: json['productname'] ?? 'Unknown',
          description: json['description'],
          price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
          hsncode: json['hsncode'],
        ),
        quantity: json['qty'] ?? json['quantity'] ?? 1,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': product.id,
      'productname': product.productname,
      if (product.description != null) 'description': product.description,
      'price': product.price,
      if (product.hsncode != null) 'hsncode': product.hsncode,
      'qty': quantity,
    };
  }
}

class InvoiceModel {
  final String? id;
  final String? invoiceNumber;
  final String invoiceDate;
  final String type;
  final Map<String, dynamic> customerData;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double totalDiscount;
  final double taxableAmount;
  final bool isGstApplied;
  final double cgst;
  final double sgst;
  final double igst;
  final double roundOff;
  final double grandTotal;
  final String? shippedto;
  final String? termsnotes;
  final int? reminderdays;

  InvoiceModel({
    this.id,
    this.invoiceNumber,
    required this.invoiceDate,
    required this.type,
    required this.customerData,
    required this.items,
    required this.subtotal,
    this.totalDiscount = 0,
    required this.taxableAmount,
    required this.isGstApplied,
    required this.cgst,
    required this.sgst,
    required this.igst,
    this.roundOff = 0,
    required this.grandTotal,
    this.shippedto,
    this.termsnotes,
    this.reminderdays,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    var itemsRaw = json['items'];
    if (itemsRaw is String) {
      try {
        itemsRaw = jsonDecode(itemsRaw);
      } catch (_) {}
    }
    var itemsList = itemsRaw as List? ?? [];
    List<InvoiceItemModel> items = itemsList.map((i) => InvoiceItemModel.fromJson(i)).toList();

    var customerDataRaw = json['customerData'];
    if (customerDataRaw is String) {
      try {
        customerDataRaw = jsonDecode(customerDataRaw);
      } catch (_) {}
    }
    
    if (customerDataRaw is List && customerDataRaw.isNotEmpty) {
      customerDataRaw = customerDataRaw.first;
    }

    Map<String, dynamic> customerDataMap = <String, dynamic>{};
    if (customerDataRaw is Map) {
      customerDataMap = Map<String, dynamic>.from(customerDataRaw);
    }

    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: json['invoiceDate'] ?? '',
      type: json['type'] ?? 'Tax Invoice',
      customerData: customerDataMap,
      items: items,
      subtotal: json['subtotal'] != null ? double.parse(json['subtotal'].toString()) : 0.0,
      totalDiscount: json['totalDiscount'] != null ? double.parse(json['totalDiscount'].toString()) : 0.0,
      taxableAmount: json['taxableAmount'] != null ? double.parse(json['taxableAmount'].toString()) : 0.0,
      isGstApplied: json['isGstApplied'] ?? true,
      cgst: json['cgst'] != null ? double.parse(json['cgst'].toString()) : 0.0,
      sgst: json['sgst'] != null ? double.parse(json['sgst'].toString()) : 0.0,
      igst: json['igst'] != null ? double.parse(json['igst'].toString()) : 0.0,
      roundOff: json['roundOff'] != null ? double.parse(json['roundOff'].toString()) : 0.0,
      grandTotal: json['grandTotal'] != null ? double.parse(json['grandTotal'].toString()) : 0.0,
      shippedto: json['shippedto'],
      termsnotes: json['termsnotes'],
      reminderdays: json['reminderdays'] != null ? int.tryParse(json['reminderdays'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate,
      'type': type,
      'customerData': customerData,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'taxableAmount': taxableAmount,
      'isGstApplied': isGstApplied,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      if (shippedto != null) 'shippedto': shippedto,
      if (termsnotes != null) 'termsnotes': termsnotes,
      if (reminderdays != null) 'reminderdays': reminderdays,
    };
  }
}
