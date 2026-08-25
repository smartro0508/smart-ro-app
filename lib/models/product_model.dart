import 'dart:convert';

class ProductModel {
  final String? id;
  final String name;
  final String? slug;
  final String? shortDescription;
  final String? description;
  final double? originalPrice;
  final double? discount;
  final double price;
  final List<String>? features;
  final Map<String, dynamic>? specifications;
  final String? warranty;
  final String? status;
  final bool? isFeatured;
  final String? mainImage;

  ProductModel({
    this.id,
    required this.name,
    this.slug,
    this.shortDescription,
    this.description,
    this.originalPrice,
    this.discount,
    required this.price,
    this.features,
    this.specifications,
    this.warranty,
    this.status,
    this.isFeatured,
    this.mainImage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedFeatures;
    if (json['features'] != null) {
      try {
        parsedFeatures = json['features'] is String ? List<String>.from(jsonDecode(json['features'])) : List<String>.from(json['features']);
      } catch (_) {}
    }

    Map<String, dynamic>? parsedSpecs;
    if (json['specifications'] != null) {
      try {
        parsedSpecs = json['specifications'] is String ? Map<String, dynamic>.from(jsonDecode(json['specifications'])) : Map<String, dynamic>.from(json['specifications']);
      } catch (_) {}
    }

    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      slug: json['slug'],
      shortDescription: json['shortDescription'],
      description: json['description'],
      originalPrice: json['originalPrice'] != null ? double.parse(json['originalPrice'].toString()) : null,
      discount: json['discount'] != null ? double.parse(json['discount'].toString()) : null,
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      features: parsedFeatures,
      specifications: parsedSpecs,
      warranty: json['warranty'],
      status: json['status'],
      isFeatured: json['isFeatured'] == 1 || json['isFeatured'] == true || json['isFeatured'] == 'true',
      mainImage: json['mainImage'],
    );
  }
}

