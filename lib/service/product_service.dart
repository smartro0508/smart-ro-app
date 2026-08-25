import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../utils/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  late Dio _dio;

  ProductService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        var box = Hive.box('authBox');
        String? token = box.get('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.post('/products/search', data: {'q': query});
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search products');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to search products');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.post('/products/get-all');
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch products');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> createProduct(ProductModel product, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': product.name,
        if (product.shortDescription != null) 'shortDescription': product.shortDescription,
        if (product.description != null) 'description': product.description,
        if (product.originalPrice != null) 'originalPrice': product.originalPrice,
        if (product.discount != null) 'discount': product.discount,
        'price': product.price,
        if (product.features != null) 'features': jsonEncode(product.features),
        if (product.specifications != null) 'specifications': jsonEncode(product.specifications),
        if (product.warranty != null) 'warranty': product.warranty,
        if (product.status != null) 'status': product.status,
        if (product.isFeatured != null) 'isFeatured': product.isFeatured,
      };

      final formData = FormData.fromMap(dataMap);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'mainImage',
          MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: imageFile.name),
        ));
      }

      final response = await _dio.post('/products/create', data: formData);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create product');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create product');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> updateProduct(ProductModel product, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': product.name,
        if (product.shortDescription != null) 'shortDescription': product.shortDescription,
        if (product.description != null) 'description': product.description,
        if (product.originalPrice != null) 'originalPrice': product.originalPrice,
        if (product.discount != null) 'discount': product.discount,
        'price': product.price,
        if (product.features != null) 'features': jsonEncode(product.features),
        if (product.specifications != null) 'specifications': jsonEncode(product.specifications),
        if (product.warranty != null) 'warranty': product.warranty,
        if (product.status != null) 'status': product.status,
        if (product.isFeatured != null) 'isFeatured': product.isFeatured,
      };

      final formData = FormData.fromMap(dataMap);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'mainImage',
          MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: imageFile.name),
        ));
      }

      final response = await _dio.post('/products/update/${product.id}', data: formData);
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update product');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _dio.post('/products/delete/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete product');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete product');
      }
      throw Exception('Network error occurred');
    }
  }
}
