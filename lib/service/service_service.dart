import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/api_constants.dart';
import '../models/service_model.dart';

class ServiceService {
  late Dio _dio;

  ServiceService() {
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

  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final response = await _dio.post('/invoice-services/search', data: {'q': query});
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search services');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _dio.post('/invoice-services/get-all');
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch services');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> createService(ServiceModel service) async {
    try {
      final response = await _dio.post('/invoice-services/create', data: service.toJson());
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create service');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      final response = await _dio.post('/invoice-services/update/${service.id}', data: service.toJson());
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update service');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final response = await _dio.post('/invoice-services/delete/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete service');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }
}
