import '../models/invoice_model.dart';

abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceModel> invoices;
  final bool hasReachedMax;
  InvoiceLoaded(this.invoices, {this.hasReachedMax = false});
}

class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}

class InvoiceAdding extends InvoiceState {}

class InvoiceAdded extends InvoiceState {
  final InvoiceModel invoice;
  InvoiceAdded(this.invoice);
}

class InvoiceAddError extends InvoiceState {
  final String message;
  InvoiceAddError(this.message);
}
