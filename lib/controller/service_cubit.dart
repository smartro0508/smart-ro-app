import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service_model.dart';
import '../service/service_service.dart';
import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceService _serviceService;
  List<ServiceModel> _allServices = [];

  ServiceCubit(this._serviceService) : super(ServiceInitial());

  Future<void> getServices({bool refresh = false}) async {
    if (!refresh && state is ServiceLoaded) return;
    emit(ServiceLoading());
    try {
      _allServices = await _serviceService.getServices();
      emit(ServiceLoaded(_allServices));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  void searchServices(String query) {
    if (query.isEmpty) {
      emit(ServiceLoaded(_allServices));
      return;
    }
    final filtered = _allServices.where((s) => s.servicename.toLowerCase().contains(query.toLowerCase())).toList();
    emit(ServiceLoaded(filtered));
  }

  Future<void> addService(ServiceModel service, {XFile? imageFile}) async {
    emit(ServiceAdding());
    try {
      await _serviceService.createService(service, imageFile: imageFile);
      emit(ServiceAdded());
      getServices(refresh: true);
    } catch (e) {
      emit(ServiceAddError(e.toString()));
    }
  }

  Future<void> updateService(ServiceModel service, {XFile? imageFile}) async {
    emit(ServiceAdding());
    try {
      await _serviceService.updateService(service, imageFile: imageFile);
      emit(ServiceAdded());
      getServices(refresh: true);
    } catch (e) {
      emit(ServiceAddError(e.toString()));
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _serviceService.deleteService(id);
      getServices(refresh: true);
    } catch (e) {
      // Silently handle error
    }
  }
}
