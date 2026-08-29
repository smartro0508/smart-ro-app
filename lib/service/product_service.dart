import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      final response = await _dio.post('/invoice-products/search', data: {'q': query});
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.post('/invoice-products/get-all');
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> createProduct(ProductModel product) async {
    try {
      final response = await _dio.post('/invoice-products/create', data: product.toJson());
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create product');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      final response = await _dio.post('/invoice-products/update/${product.id}', data: product.toJson());
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _dio.post('/invoice-products/delete/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete product');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }
}
