import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/api_constants.dart';
import '../models/setting_model.dart';

class SettingService {
  late Dio _dio;

  SettingService() {
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

  Future<SettingModel> getSettings() async {
    try {
      final response = await _dio.post('/settings/get');
      if (response.statusCode == 200) {
        return SettingModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load settings');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to load settings');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<SettingModel> updateSettings(SettingModel settings) async {
    try {
      final response = await _dio.post('/settings/update', data: settings.toJson());
      if (response.statusCode == 200) {
        return SettingModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update settings');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update settings');
      }
      throw Exception('Network error occurred');
    }
  }
}
