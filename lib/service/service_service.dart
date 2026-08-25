import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
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
      final response = await _dio.post('/services/search', data: {'q': query});
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search services');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to search services');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _dio.post('/services/get-all');
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch services');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch services');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> createService(ServiceModel service, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> dataMap = {
        'servicename': service.servicename,
        if (service.description != null) 'description': service.description,
        'servicecost': service.servicecost,
        'serviceproductcost': service.serviceproductcost,
        if (service.keypoints != null) 'keypoints': jsonEncode(service.keypoints),
        if (service.status != null) 'status': service.status,
      };

      final formData = FormData.fromMap(dataMap);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: imageFile.name),
        ));
      }

      final response = await _dio.post('/services/create', data: formData);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create service');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create service');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> updateService(ServiceModel service, {XFile? imageFile}) async {
    try {
      final Map<String, dynamic> dataMap = {
        'servicename': service.servicename,
        if (service.description != null) 'description': service.description,
        'servicecost': service.servicecost,
        'serviceproductcost': service.serviceproductcost,
        if (service.keypoints != null) 'keypoints': jsonEncode(service.keypoints),
        if (service.status != null) 'status': service.status,
      };

      final formData = FormData.fromMap(dataMap);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(await imageFile.readAsBytes(), filename: imageFile.name),
        ));
      }

      final response = await _dio.post('/services/update/${service.id}', data: formData);
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update service');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update service');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final response = await _dio.post('/services/delete/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete service');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete service');
      }
      throw Exception('Network error occurred');
    }
  }
}
