class ProductModel {
  final String? id;
  final String productname;
  final String? description;
  final double price;

  String get name => productname;

  ProductModel({
    this.id,
    required this.productname,
    this.description,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      productname: json['productname'] ?? json['name'] ?? '',
      description: json['description'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productname': productname,
      if (description != null) 'description': description,
      'price': price,
    };
  }
}
