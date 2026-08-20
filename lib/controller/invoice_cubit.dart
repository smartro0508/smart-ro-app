import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/invoice_service.dart';
import '../models/invoice_model.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceService _invoiceService;
  List<InvoiceModel> _invoices = [];
  int _page = 1;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  String? fromDate;
  String? toDate;

  InvoiceCubit(this._invoiceService) : super(InvoiceInitial()) {
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    toDate = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];
  }

  void updateDates(String from, String to) {
    fromDate = from;
    toDate = to;
    getInvoices(refresh: true);
  }

  void getInvoices({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasReachedMax = false;
      _invoices.clear();
      emit(InvoiceLoading());
    } else if (_hasReachedMax) {
      return;
    }

    _isLoading = true;
    try {
      final newInvoices = await _invoiceService.getInvoices(page: _page, limit: 30, fromDate: fromDate, toDate: toDate);
      if (newInvoices.length < 30) {
        _hasReachedMax = true;
      }
      _invoices.addAll(newInvoices);
      _page++;
      emit(InvoiceLoaded(List.from(_invoices), hasReachedMax: _hasReachedMax));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(InvoiceError(errorMessage));
    } finally {
      _isLoading = false;
    }
  }

  void addInvoice(InvoiceModel invoice) async {
    emit(InvoiceAdding());
    try {
      await _invoiceService.createInvoice(invoice);
      emit(InvoiceAdded(invoice));
      getInvoices(refresh: true);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(InvoiceAddError(errorMessage));
      if (_invoices.isNotEmpty) {
        emit(InvoiceLoaded(List.from(_invoices), hasReachedMax: _hasReachedMax));
      }
    }
  }
}
