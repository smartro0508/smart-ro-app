import '../models/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final bool hasReachedMax;
  CustomerLoaded(this.customers, {this.hasReachedMax = false});
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

class CustomerAdding extends CustomerState {}

class CustomerAdded extends CustomerState {}

class CustomerAddError extends CustomerState {
  final String message;
  CustomerAddError(this.message);
}
