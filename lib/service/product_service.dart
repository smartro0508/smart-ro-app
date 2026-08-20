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
}
