import '../models/service_model.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  ServiceLoaded(this.services);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}

class ServiceAdding extends ServiceState {}

class ServiceAdded extends ServiceState {}

class ServiceAddError extends ServiceState {
  final String message;
  ServiceAddError(this.message);
}
