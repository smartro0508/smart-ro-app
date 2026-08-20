import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/customer_service.dart';
import '../models/customer_model.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerService _customerService;
  final List<CustomerModel> _customers = [];
  int _page = 1;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  String? fromDate;
  String? toDate;

  CustomerCubit(this._customerService) : super(CustomerInitial()) {
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    toDate = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];
  }

  void updateDates(String from, String to) {
    fromDate = from;
    toDate = to;
    getCustomers(refresh: true);
  }

  void getCustomers({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasReachedMax = false;
      _customers.clear();
      emit(CustomerLoading());
    } else if (_hasReachedMax) {
      return;
    }

    _isLoading = true;
    try {
      final newCustomers = await _customerService.getCustomers(page: _page, limit: 30, fromDate: fromDate, toDate: toDate);
      if (newCustomers.length < 30) {
        _hasReachedMax = true;
      }
      _customers.addAll(newCustomers);
      _page++;
      emit(CustomerLoaded(List.from(_customers), hasReachedMax: _hasReachedMax));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(CustomerError(errorMessage));
    } finally {
      _isLoading = false;
    }
  }

  void addCustomer(CustomerModel customer) async {
    emit(CustomerAdding());
    try {
      await _customerService.createCustomer(customer);
      emit(CustomerAdded());
      getCustomers(refresh: true);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(CustomerAddError(errorMessage));
      if (_customers.isNotEmpty) {
        emit(CustomerLoaded(List.from(_customers), hasReachedMax: _hasReachedMax));
      }
    }
  }
}
