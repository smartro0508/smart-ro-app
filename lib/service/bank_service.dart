import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/api_constants.dart';
import '../models/bank_model.dart';

class BankService {
  late Dio _dio;

  BankService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          var box = Hive.box('authBox');
          String? token = box.get('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<BankModel?> getBankDetails() async {
    try {
      final response = await _dio.post('/banks/get');
      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          return BankModel.fromJson(response.data['data']);
        }
        return null;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load bank details',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Treat 404 as no bank added yet
      }
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to load bank details',
        );
      }
      throw Exception('Network error occurred');
    }
  }

  Future<BankModel> createBank(BankModel bank) async {
    try {
      final response = await _dio.post('/banks/update', data: bank.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return BankModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to create bank details',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to create bank details',
        );
      }
      throw Exception('Network error occurred');
    }
  }

  Future<BankModel> updateBank(BankModel bank) async {
    try {
      final response = await _dio.post(
        '/banks/update',
        data: bank.toJson(),
      );
      if (response.statusCode == 200) {
        return BankModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update bank details',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update bank details',
        );
      }
      throw Exception('Network error occurred');
    }
  }
}
