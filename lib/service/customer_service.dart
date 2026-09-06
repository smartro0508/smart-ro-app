import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/api_constants.dart';
import '../models/customer_model.dart';

class CustomerService {
  late Dio _dio;

  CustomerService() {
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

  Future<List<CustomerModel>> getCustomers({int page = 1, int limit = 30, String? fromDate, String? toDate}) async {
    try {
      final Map<String, dynamic> data = {'page': page, 'limit': limit};
      if (fromDate != null) data['fromDate'] = fromDate;
      if (toDate != null) data['toDate'] = toDate;
      
      final response = await _dio.post('/customers/get-all', data: data);
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((e) => CustomerModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load customers');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to load customers');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final response = await _dio.post('/customers/search', data: {'q': query});
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((e) => CustomerModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search customers');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to search customers');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> createCustomer(CustomerModel customer) async {
    try {
      final response = await _dio.post('/customers/create', data: customer.toJson());
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create customer');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create customer');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<CustomerModel> getCustomer(String id) async {
    try {
      final response = await _dio.post('/customers/get/$id');
      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load customer');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to load customer');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> updateCustomer(String id, CustomerModel customer) async {
    try {
      final response = await _dio.post('/customers/update/$id', data: customer.toJson());
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to update customer');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update customer');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final response = await _dio.post('/customers/delete/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete customer');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete customer');
      }
      throw Exception('Network error occurred');
    }
  }
}
