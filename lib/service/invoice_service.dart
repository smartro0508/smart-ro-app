import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/api_constants.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  late Dio _dio;

  InvoiceService() {
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

  Future<List<InvoiceModel>> getInvoices({int page = 1, int limit = 30, String? fromDate, String? toDate}) async {
    try {
      final Map<String, dynamic> data = {'page': page, 'limit': limit};
      if (fromDate != null) data['fromDate'] = fromDate;
      if (toDate != null) data['toDate'] = toDate;

      final response = await _dio.post('/invoices/get-all', data: data);
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        return data.map((json) => InvoiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load invoices');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to load invoices');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    try {
      final response = await _dio.post('/invoices/create', data: invoice.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return InvoiceModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create invoice');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create invoice');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<InvoiceModel> updateInvoice(String id, InvoiceModel invoice) async {
    try {
      final response = await _dio.post('/invoices/update/$id', data: invoice.toJson());
      if (response.statusCode == 200) {
        return InvoiceModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update invoice');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update invoice');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final response = await _dio.post('/invoices/delete/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Failed to delete invoice');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete invoice');
      }
      throw Exception('Network error occurred');
    }
  }
}
